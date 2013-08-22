---
layout: post
title: "Эксперименты с OpenStruct и JSON-схемами"
date: 2013-04-22 15:24
comments: true
categories: 
---
Недавно мы решили выделить логические компоненты внутри нашего большого рейлс-приложения, чтобы в будущем возможно разделить приложение физически. Для стандартизации общения между частями системы я использовал JSON-совместимые объекты с валидацией при помощи JSON-схем и немного доработанный OpenStruct. Про этот эксперимент я и хочу рассказать в сегодняшней статье.

## Заменить хэши на OpenStruct

Мне нравятся `OpenStruct` структуры, пример использования которых можно посмотреть в [официальной документации](http://ruby-doc.org/stdlib-1.9.3/libdoc/ostruct/rdoc/OpenStruct.html):

``` ruby
require 'ostruct'

person = OpenStruct.new
person.name    = "John Smith"
person.age     = 70
person.pension = 300

puts person.name     # -> "John Smith"
puts person.age      # -> 70
puts person.address  # -> nil
```

Мне кажется гораздо приятнее написать в коде `person.address.street`, чем `person[:address][:street]` однако по привычке обычно используют вторую запись. В рамках эксперимента я изменил несколько методов в `OpenStruct`:

``` ruby config/initializer/monkey_patching.rb
class OpenStruct
  def as_json
    marshal_dump.as_json
  end
  
  def to_json
    marshal_dump.to_json
  end

  def to_s
    marshal_dump.to_s
  end

  def inspect
    to_s
  end
end
```

сделав тем самым `OpenStruct` полностью совместимыми с обычными хэшами в рамках наших задач:

``` ruby
# До изменения (в JSON появляется лишняя вложенность элементов структуры,
# инспект-запись объекта более громоздкая чем в обычном хэше)
OpenStruct.new(a: 3, b: [1, 2]).to_json   # => "{\"table\":{\"a\":3,\"b\":[1,2]}}"
OpenStruct.new(a: 3, b: [1, 2]).as_json   # => {"table"=>{:a=>3, :b=>[1, 2]}}
OpenStruct.new(a: 3, b: [1, 2]).inspect   # => "#<OpenStruct a=3, b=[1, 2]>"

# После изменения
OpenStruct.new(a: 3, b: [1, 2]).to_json   # => "{\"a\":3,\"b\":[1,2]}"
OpenStruct.new(a: 3, b: [1, 2]).as_json   # => {"a"=>3, "b"=>[1, 2]}
OpenStruct.new(a: 3, b: [1, 2]).inspect   # => "{:a=>3, :b=>[1, 2]}"

# Стандартный хэш
{a: 3, b: [1, 2]}.to_json      # => "{\"a\":3,\"b\":[1,2]}"
{a: 3, b: [1, 2]}.as_json      # => {"a"=>3, "b"=>[1, 2]}
{a: 3, b: [1, 2]}.inspect      # => "{:a=>3, :b=>[1, 2]}"
```


## JSON Schema

Веселый гибкий JSON пришел на смену жуткому XML с DTD таблицами. Однако после глотка свободы обязательно следует затянуть гайки. Поэтому люди придумали [JSON Schema](http://json-schema.org/), который сейчас проходит [третье чтение](http://tools.ietf.org/html/draft-zyp-json-schema-03) в органиции IETF. JSON Schema позволяет валидировать корректность JSON-объекта, проверять типы полей и простые граничные условия. В нашем проекте я использовал гем [json-schema](https://github.com/hoxworth/json-schema), который может валидировать руби-объекты по такой же схеме как и Javascript-объекты. 

Для работы системы с первым логическим компонентов я создал интерфейсный модуль с стаческими методами, используя шаблон проектирования [PIMPL](http://c2.com/cgi/wiki?PimplIdiom).

Рассмотрим организации валидации значения на примере интерфейсного метода `get_users`,
который возвращает массив пользователей, используя указатель на реализацию интерфейса `impl`.
Возвращаемое значение проходит проверку на соответствие его JSON-схеме, заданной в модуле.

Обратите внимание на ключ `additionalProperties`, который я всегда выставляю для объектов в `false`,
чтобы запретить использование свойств, не описанных в схеме.
Также посмотрите на ограничения, наложенные на свойство `age`.
Возраст является не обязательным, но если он все-таки указан, то он должен
быть числом не меньше 5 и не больше 120.

Если возвращаемое значение не совпадает с заявленной схемой, то `JSON::Validator.validate!` вызовет эксепшн.

``` ruby
module LogicComponent
  mattr_accessor :impl

  USERS_SCHEMA = {
    type: "array",
    items: {
      type: "object",
      additionalProperties: false,
      properties: {
        lname: { type: "string", required: true },
        fname: { type: "string", required: true },
        age: { type: "integer", required: false, minimum: 5, maximum: 120 }
      }
    }
  }

  class << self
    # LogicComponent.init вызывается в инициализаторе рейлс-приложения
    def init
      self.impl = LogicComponent::Impl.new
    end

    def get_users(country)
      impl.get_users(country).tap do |out|
        JSON::Validator.validate!(USERS_SCHEMA.as_json, out.as_json)
      end
    end
  end
end
```

Простая реализация impl-части (удобно вынести функционал в отдельный класс, чтобы было легче
тестировать и, например, использовать кеширование `@member ||= ...`):

``` ruby
module LogicComponent
  class Impl
    def get_users(country)
      if country == 'Russia'
        [
          OpenStruct.new(fname: 'Alexey', lname: 'Vakhov', age: 29)
        ]
      else
        []
      end
    end
  end
end
```

И наконец практическое применение, для работы с результатом используем магию `OpenStruct`:

``` ruby
LogicComponent.init
LogicComponent.get_users("Russia").first.tap do |user|
  puts user.fname   # => "Alexey"
  puts user.lname   # => "Vakhov"
  puts user.age     # => 29
end
```

Подобным образом можно реализовать все необходимые методы модуля `LogicComponent`.

## Итоги

Во многих случаях структуры `OpenStruct` являются полноценной и более удобной заменой внутренних хешей.

Использовать стандартизированных JSON-схем в руби для проверки входных параметров и результатов во
внутреннем API мне очень понравилось. Эта идея перекликается с методологией программирования
по контракту, которая мне также симпатична. Не знаю как обстоят дела с производительностью гема
`json-schema`, однако идеологически решение получается очень приятным.
