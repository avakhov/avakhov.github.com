---
title: Простой Haml генератор статических сайтов
---

Для нашей компании мы решили сделать максимально простой сайт, разместив на белом фоне несколько 
блоков с информацией. Я решил взять сетку 
твиттер бутстрап-фрейморка и обойтись без помощи дизайнера и верстальщика. Верстка для бутстрапа
требует довольно большое количество вложенных дивов, поэтому лучше всего использовать Haml, 
с разбивкой содержания на несколько партиалов. Статические сайты обычно удобно делать с помощью Jekyll,
но я не знаю насколько сложно добавить поддержку хамл к Jekyll и возможно ли это сделать быстро. 
В нашем случае данную задачу можно решить c помощью нескольких простых скриптов.

Итак, скачиваем исходники бутстрап с [официальной страницы
проекта](http://twitter.github.com/bootstrap/) в папку проекта. Создаем директорию views,
добавляем хамл-файлы:

``` haml
-# views/index.haml
!!! 5
%html
  %head
    -# ...
%body
  .container
    = partial :header
    -# ...
```

``` haml
-# views/_header.haml
.header
  %h1 Logo
```
 
Создаем файл который будет собирать наш сайт в папку _site:

``` ruby
# make.rb
require 'haml'

`rm -fr _site && mkdir _site`
`cp -r bootstrap _site`

puts "generate index.html"
engine = ::Haml::Engine.new(File.read('views/index.haml'))
File.open("_site/index.html", "w"){|f| f.write engine.render}
```

Запускаем файл make.rb и получаем ошибку Unknown method 'partial'.
В наш генератор необходимо добавить поддержку паршиалов.

У [Haml::Engine#render](http://haml-lang.com/docs/yardoc/Haml/Engine.html#render-instance_method)
метода есть параметр scope, который позволяет выполнить код хамла в контексте произвольного объекта.
Реализуем простой паршиал и запустим make.rb снова:

``` ruby
# ...

class Helpers
  def partial(template)
    ::Haml::Engine.new(File.read("views/_#{template}.haml")).render(Helpers.new)
  end
end

engine = ::Haml::Engine.new(File.read('views/index.haml'))
File.open("_site/index.html", "w"){|f| f.write engine.render(Helpers.new)}
```

Теперь скрипт выполнится правильно и создаст готовый сайт в папке _site.

Для удобства разработки добавим гард:

``` ruby
# Guardfile
ignore_paths '_site'
guard :shell do
  watch(/.*/) { `./make.rb` }
end
```

а также скрипт деплоя готового сайта:

``` bash
# deploy.sh
./make.rb
rsync -aP --del _site/ server:/www/site
```

Таким образом очень быстро мы получили готовый генератор простых статических сайтов.
Примером сайта выполненного по этой технологии является [сайт нашей компании](http://boshie.com).

В качестве дополнительного плюса, при использовании haml, исходный код вашего сайта будет рисоваться
симпатичной змейкой.

![](/assets/1/zip-zip.png)

__Update:__ Есть шутка, что нет смысла чему-то долго учиться, потому-что всегда
на ютубе будет много роликов, где кто-нибудь это делает в 10 раз лучше.
Так и в руби, на любую идею уже есть красиво оформленный гем. 
Вот ссылки на генераторы статических сайтов, которые посоветовали коллеги в комментариях:

* [http://middlemanapp.com/](http://middlemanapp.com/)
* [http://stasis.me/](http://stasis.me/)
