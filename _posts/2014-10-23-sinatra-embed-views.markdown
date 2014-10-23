---
title: Синатра инлайн-темплейты
image: /assets/sinatra-embed-views.jpg
---

В руби можно закончить скрипт досрочно, а Синатра позволяет разместить там вьюхи. Но давайте обо всем
по порядку.

Любой текст, который встретится в руби-скрипте за маркером `__END__` проигнорируется во время 
выполнения, но будет доступен в скрипте, через IO-объект `DATA`. В блоге Causis Theory можно найти
несколько любопытных примеров использования этой фичи [<i class="fa fa-external-link"></i>](http://caiustheory.com/why-i-love-data/), самый приличный из которых, как мне кажется:

``` ruby
DATA.each_line.map(&:chomp).each do |url|
  `open "#{url}"`
end

__END__
http://google.com/
http://yahoo.com/
```

Во фрейморке Синатра пошли еще дальше и предложили использовать подвал скрипта для внедрения 
именованных вьюх.
Этот прием называется Inline <nobr>Templates [<i class="fa fa-external-link"></i>](https://github.com/sinatra/sinatra/blob/v1.4.5/README.md#inline-templates)</nobr> и позволяет, ну вы сами видите, что он позволяет делать:

``` ruby
require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

__END__

@@ layout
<html>
  <body>
    <%= yield %>
  </body>
</html>

@@ index
<div>Hello!</div>
```

Снимаю шляпу перед очередной экзотической штучкой мира руби.
