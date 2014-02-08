---
layout: post
title: "3 способа автоматического тестирования Javascript"
date: 2012-11-06 13:28
comments: true
categories: 
---
С++ я уважал за мощь и строгость, Руби обожаю за работу с строками, массивами и хэшами, но к Javascript всегда относился и продолжаю
относится холодно. Мне не нравится как осуществляется работа с `this`, смущает обилие операторов и зарезервированных
слов `undefined`, `null`, `Infinite`, `Nan`, `==`, `===`, а также я плохо ориентируются в колбеках. Кроме того, я не прочитал
ни одной книги по Javascript, что конечно же не способствует установлению приятельских отношений с этим языком.

Однако в ближайшие лет 5 вряд ли появится альтернатива для разработки на стороне клиента, поэтому с javascript придется работать еще
очень долго. В проекте, в котором я сейчас работаю, накопилось достаточно большое количество клиентского кода и пришла пора его тестировать
автоматически. Так как тема для меня новая, то я провел несколько эспериментов и
сегодня хочу предложить вашему вниманию 3 простых способа сделать ваш javascript более надежным.

Оговорюсь, что у нас простой интерфейс, однако есть сложные алгоритмические куски кода на javascript. Поэтому наши задачи идеально
подходят под классическое юнит-тестирование, про которое я буду рассказывать сегодня. Как тестировать сложный UI я
пока не знаю, так как с такой задачей еще не сталкивался.

## Способ 1. ExecJS

Предположим, что нам нужно протестировать функцию, которая удаляет все элементы массива, совпадающие с заданным:

``` javascript
// Удаляет все элементы e из массива
Array.prototype.remove = function(e) {
  for (var i = 0; i < this.length; i++) {
    if (this[i] === e) {
      this.splice(i, 1);
      i--;
    }
  }
  return this;
};
```

Автоматические тесты запускаются на сервере после каждого комита, поэтому желательно, что бы js-тесты встроились в этот процесс.
К счастью в любом рейлс-приложении у нас уже есть все необходимые компоненты.
Гем [execjs](https://github.com/sstephenson/execjs), который используется при компилиции coffee-ассетов, можно использовать
для выполнения произвольного кода на сервере.

Добавляем `execjs` в секцию `test`:

``` ruby
group :test do
  gem 'execjs'
end
```

Создаем спек для тестирования:

``` ruby
require 'spec_helper'

describe "array.js" do
  it "implements Array#remove method" do
    # Тестовые случаи
    spec = <<-JS
      var r1 = [1, 2, 2, 3].remove(2)
      var r2 = [1, 1, 1, 1].remove(1)
      // ...
    JS

    # Создаем контекст
    src = File.read(Rails.root.join('app/assets/javascripts/array.js'))
    js_context = ExecJS.compile(src + spec)

    # Проверка ожиданий
    js_context.eval('r1').should == [1, 3]
    js_context.eval('r2').should == []
    # ...
  end
end
```

Запускаем спеки:

``` bash
~/proj/blog-2-js-testing(1.9.3-p194)[master]$ rspec
..

Finished in 0.32502 seconds
1 example, 0 failures
```

Вуаля, работает! Таким образом уже можно писать простые спеки.

Если файл, который нужно протестировать, написан на coffee-скрипте, то его можно скомпилировать с помощью гема `coffee-script`,
который также подключен к каждому рейлс-приложению:

``` ruby
group :test do
  gem 'execjs'
  gem 'coffee-script'
end
```

компилируем его следующим образом:

``` ruby
  coffee = File.read(Rails.root.join('app/assets/javascripts/array.js'))
  src = CoffeeScript.compile(coffee)
  js_context = ExecJS.compile(src)
```

Конечно такого рода код для работы с js-файлами лучше выделить в отдельное место, но для проверки технологии можно оставить и так.

У данного метода тестирования есть много недостатков, главными из которых на мой взгляд являются: смешение js- и руби-кода в одном
файле, а также возможная потеря информации на границе ruby и скрипта (`undefined`, `null`, `Infinite` все перейдут в `nil`, кроме того
можно проверить только json-совместимые результаты). Главный положительный момент - тестирование органично встраивается
в регулярный прогон тестов и не требует никаких дополнительных настроек.

## Способ 2. Jasmine + ExecJS

Я слышал положительные отзывы о библиотеке [jasmine](http://pivotal.github.com/jasmine/). Синтаксис выглядит приятно и rspec-подобно.
Поэтому решил модернизировать способ 1, чтобы писать спеки на чистом js (coffee).

Скачиваем файлы [jasmine.js](https://github.com/pivotal/jasmine/blob/master/lib/jasmine-core/jasmine.js) и [ConsoleReporter.js](https://github.com/pivotal/jasmine/blob/master/src/console/ConsoleReporter.js), помещаем их в `vendor/assets/javascripts`.

Создаем файл, который будет запускать js-спеки. Он выглядит немного сложно, но так всегда происходит, когда мы начинаем
решать нестандартную задачу на стыке языков.

``` ruby
# encoding: utf-8
require 'spec_helper'

# Запустить js-спеки, используя jasmine и execjs
describe 'JS specs' do
  def assets(js_files)
    Array(js_files).map{ |js_file|
      if File.extname(js_file) == '.coffee'
        CoffeeScript.compile File.read(Rails.root.join(js_file))
      else
        File.read(Rails.root.join(js_file))
      end
    }.join("\n")
  end

  ASSETS = [
    'vendor/assets/javascripts/jasmine.js',
    'vendor/assets/javascripts/ConsoleReporter.js',
    
    'app/assets/javascripts/array.js'
  ]

  Dir[Rails.root.join('spec/javascripts/**/*_spec.js*')].each do |asset|
    it "passed #{Pathname.new(asset).relative_path_from(Rails.root)}" do
      # Подкладываем переменную `exports`, которая нужна jasmine.js
      src = "var exports = {};\n"

      # Загружаем жасмин и тестируемый файл
      src += assets(ASSETS + [asset])

      # Подключаем jasmine reporter
      src += <<-JS
        var out = "";
        var env = jasmine.getEnv();
        
        // Собирать вывод мы будем в переменную `out`
        var reporter = new jasmine.ConsoleReporter(function(msg){ out += msg; });

        // Скажем jasmine не использовать setTimeout и все сделать в один поток
        env.updateInterval = null;

        // Запускаем js-cпеки
        env.addReporter(reporter);
        env.execute();
      JS

      js_context = ExecJS.compile(src)

      # Используем assert, чтобы вывод в случае ошибки был понятнее
      out = js_context.eval('out')
      js_specs_passed = (out =~ /\d+ specs?, 0 failures/)
      assert js_specs_passed, out
    end
  end
end
```

Пишем наш первый спек с помощью жасмина:

``` coffeescript
describe 'Array', ->
  it "#remove", ->
    expect([1, 2, 2, 3].remove(2)).toEqual([1, 3])
    expect([1, 1, 1, 1].remove(2)).toEqual([])
```

Запускаем:

``` bash
~/proj/blog-2-js-testing(1.9.3-p194)[master]$ rspec
..

Finished in 0.57251 seconds
2 examples, 0 failures
```

Ура! Спеки пройдены.

Данный способ мне идеологически нравится гораздо больше, рассмотрим его недостатки:

* Не учитываются зависимости между файлами.
* Нет возможности протестировать js, который работает с DOM.
* Сложно находить ошибку, когда спеки падают.
* Плохая гибкость, так как приходится указывать файлы явно.

## Способ 3. ???

Способ 3 я еще не придумал. Мне любопытно посмотреть на `jasmine-gem` и совместить его с [phantomjs](http://phantomjs.org/).
Так же интересно поиграть с [полтергейстом](https://github.com/jonleighton/poltergeist) от Джона Лейгтона.
Я буду рад, если вы поделитесь своим опытом тестирования javascript, так как тема важная, но мне показалось, что
единого решения пока нет.

До новых встреч!

### Ссылки

* [https://github.com/sstephenson/execjs](https://github.com/sstephenson/execjs) - execjs-гем
* [https://github.com/avakhov/blog-2-js-testing](https://github.com/avakhov/blog-2-js-testing) - исходные кода демо приложения
* [http://railscasts.com/episodes/297-running-javascript-in-ruby](http://railscasts.com/episodes/297-running-javascript-in-ruby) - Running JavaScript in Ruby
* [http://pivotal.github.com/jasmine/](http://pivotal.github.com/jasmine/) - jasmine
* [Pathname#relative_path_from](http://ruby-doc.org/stdlib-1.9.3/libdoc/pathname/rdoc/Pathname.html#method-i-relative_path_from)
