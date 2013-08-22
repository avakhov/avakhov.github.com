---
layout: post
title: "DSL, select и системные методы"
date: 2012-04-11 09:48
comments: true
categories: 
---
При работе с руби иногда встречаются ошибки, которые вызывают замешательство. Недавно я создавал
простой DSL для своей библиотеки на остове метода `instance_eval` (метод весьма спорный, его нужно
использовать аккуратно, но сегодня речь не об этом). Интерпретатор руби вылетал с очень странной ошибкой,
на простом коде:

``` ruby
class Dsl
  def initialize(&block)
    @fields = []
    instance_eval(&block)
  end

  METHODS = %w[select text string]

  def method_missing(method, *args, &block)
    if METHODS.include?(method.to_s) && args.size == 1
      @fields << [method, args]
    else
      super
    end
  end
end

Dsl.new do
  string :a
  select :b  # <--- BOOM!
end
```

Трейс ошибки:

```
demo.rb:20:in `select': wrong argument type Symbol (expected Array) (TypeError)
	from demo.rb:20:in `block in <main>'
	from demo.rb:4:in `instance_eval'
	from demo.rb:4:in `initialize'
	from demo.rb:18:in `new'
	from demo.rb:18:in `<main>'
```

Сейчас меня эта ошибка не удивляет, так как я знаю в чем подвох. Но тогда я очень удивился, даже безуспешно пытался отладить
свой код.

Секрет очень простой - в руби есть системный метод `select`
([Kernel.html#method-i-select](http://www.ruby-doc.org/core-1.9.3/Kernel.html#method-i-select)) и происходит конфликт имен.
Хорошо, что я еще не "угадал" аргументы, тогда бы ошибка была бы еще сложнее.

Обойти эту проблему очень просто, необходимо объявить метод `select` в DSL явно:

``` ruby
  # ...

  METHODS = %w[text string]

  def select(name)
    @fields << [:string, name]
  end

  def method_missing(method, *args, &block)
  # ...
```

Таким образом при работе с рейлс у вас в распоряжении минимум 3 различных метода `select`: 

* хелпер метод для рисования комбобоксов;
* метод поиска по массиву (`[1, 2, 3, 4, 5].select{|a| a%2 == 0}`);
* и наш сегодняшний таинственный незнакомец.

Рейлс, как и само руби, довольно плохо защищено от конфликтов имен, так как количество
системных методов руби и внутренних методов рейлс равно бесконечности. Поэтому если
вам кажется, что интерпретатор свихнулся, возможно вы как раз поймали ошибку аналогичную описанной.

И еще один совет - не используйте класс `Config` в глобальном пространстве имен:

``` ruby
# OK
module A
  class Config
  end
end

# BAD
class Config # <-- in `<main>': Config is not a class (TypeError) 
end
```
