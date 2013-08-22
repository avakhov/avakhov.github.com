---
layout: post
title: "Лайоут для текста"
date: 2012-02-28 09:14
comments: true
categories: 
---

По умолчанию при рендеринге простого текста в контроллере он отрисовывается как есть:

``` ruby
def action
  render text: "some" # => some
end
```

Но если вы занимаетесь мета-программирования и создаете цмс или динамический скаффолд,
то пригодится рендеринг текста с лайоутом.

Это сделать очень просто:

``` ruby
def action
  render text: "some", layout: true # => "<!DOCTYPE html><html> ..."
end
```

Я не помню насколько это хорошо документировано в методе render, но данное поведение обеспечивает
[одна строчка](https://github.com/rails/rails/blob/v3.2.1/actionpack/lib/abstract_controller/layouts.rb#L421) из абстракт-контроллера.
