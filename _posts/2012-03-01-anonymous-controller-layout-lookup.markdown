---
title: Лайоут анонимного контроллера
---

В продолжении темы про лайоуты. Допустим вы решили создать анонимный контроллер, который
будет поддерживать классическую цепочку поиска подходящего лайоута согласно [документации](http://api.rubyonrails.org/classes/AbstractController/Layouts.html#label-Inheritance+Examples).

Например так:

``` ruby
# config/routes.rb
WeirdRailsApp::Application.routes.draw do
  controller = Class.new(ApplicationController) do
    def text
      render text: 'demo', layout: true
    end
  end

  root to: controller.action(:text)
end
```

Я не знаю зачем вам может понадобиться написать такой код, но никогда же нельзя
за себя ручаться, мало ли что.

Вынужден огорчить, но в сегодняшних версиях рейлс вы получите ексепшн:

```
There was no default layout for #<Class:0xa1e6cd4> in #<ActionView::PathSet:...
```

Это происходит из-за ошибки в рейлс при поиске лайоута. К счастью я нашел этот дефект и [исправил](https://github.com/rails/rails/commit/b27c29ef4a26755b8de04686241694ce5ee33724). 

В рейлс 4.0 вы сможете пользоваться привычным наследованием лайоутов и для анонимных
контроллеров тоже. Код, предложенный вверху поста, будет выполняться правильно.
