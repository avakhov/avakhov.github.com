---
layout: post
title: "Рекурсивные mustache-темплейты и SMTRails"
date: 2012-07-30 10:14
comments: true
categories: 
---
Последнее время я очень полюбил mustache-темплейты и использую их всегда, когда нужно отрисовать кусок HTML на сервере и потенциально
на клиенте. Причем я не хочу переходить на более продвинутый handlebars, так как мне кажется, что logicless-сущность mustache
помогает создать более изящную архитектуру, лучше спроектировать json'ы общения клиента и сервера и избежать соблазна сделать
erb-кашу из шаблонов.

Mustache я начал использовать после прошлогоднего ролика Райана
[Sharing Mustache Templates](http://railscasts.com/episodes/295-sharing-mustache-templates) и делал
точно по рейлскасту: подключал вручную все паршиалы, качал mustache.js и т.д. Это немного муторно, но все поменялось,
после того как [Алексей](https://twitter.com/leopard_me/) создал прекрасный гем [smt_rails](https://github.com/railsware/smt_rails).
Про `smt_rails` уже писали несколько раз, смотрите например
[статью Михаила Бортника](http://vessi.github.com/blog/2012/07/13/niemnogho-o-sovmiestnykh-shablonakh/), поэтому повторять зачем он нужен
я не буду, лучше расскажу про mustache-паршиалы и рекурсивные шаблоны, которые в `smt_rails` очень легко использовать.

Допустим вы хотите отрисовать дерево комментариев, которые сверстаны с помощью вложенных списков примерно так:

``` html
<div class="comments">
  <ul>
    <li>
      Comment #1
      <ul>
        <li>Comment #1.1</li>
        <li>Comment #1.2</li>
        <li>Comment #1.3</li>
        <li>
          Comment #1.4
          <ul>
            <li>Comment #1.4.1</li>
          </ul>
        </li>
        <li>Comment #1.5</li>
      </ul>
    </li>
    <li>Comment #2</li>
    <li>Comment #3</li>
  </ul>
</div>
```

Данный кусок HTML можно отрисовать множеством способов, но предположим что вы еще хотите обновлять
это дерево с помощью json на клиенте. Посмотрите как легко это можно сделать с помощью mustache-паршиалов:

``` ruby Gemfile
gem 'smt_rails', '>= 0.2.3'
```

{% gist 3206500 %}

{% gist 3206505 %}

Отрисовка комментариев на сервере:

``` erb
<h1>Comments</h1>
<%=
  render '/comments', mustache: {
    comments: [
      {
        text: 'Comment #1',
        children: [
          {text: 'Comment #1.1', children: [], empty: true},
          {text: 'Comment #1.2', children: [], empty: true},
          {text: 'Comment #1.3', children: [], empty: true},
          {
            text: 'Comment #1.4',
            children: [
              {text: 'Comment #1.4.1', children: [], empty: true}
            ],
            empty: false
          },
          {text: 'Comment #1.5', children: [], empty: true},
        ],
        empty: false 
      },
      {text: 'Comment #2', children: [], empty: true},
      {text: 'Comment #3', children: [], empty: true}
    ]
  }
%>
```

Отрисовка комментариев через javascript (код полностью совпадает, только для отрисовки используется вызов 
функции `SMT['имя шаблона']()` с параметрами):

``` javascript
// ...
//
// SMT Rails
//= require mustache
//= require_tree ../../templates

$(function(){
  $("#place").html(SMT['comments'](
    {
      comments: [
        {
          text: 'Comment #1',
          children: [
            {text: 'Comment #1.1', children: [], empty: true},
            {text: 'Comment #1.2', children: [], empty: true},
            {text: 'Comment #1.3', children: [], empty: true},
            {
              text: 'Comment #1.4',
              children: [
                {text: 'Comment #1.4.1', children: [], empty: true}
              ],
              empty: false
            },
            {text: 'Comment #1.5', children: [], empty: true},
          ],
          empty: false 
        },
        {text: 'Comment #2', children: [], empty: true},
        {text: 'Comment #3', children: [], empty: true}
      ]
    }
  ));
});
```

При реальной работе, конечно не нужно будет писать такие жуткие куски куда, подходящий json можно подготовить с помощью
простого хелпер-метода:

``` ruby
def comments_to_mustache(comments)
  {comments: comments.map { |comment| _comment(comment) }
end

def _comment(comment)
  {
    text: comment.text,
    children: comment.children.map { |child| _comment(child) },
    empty: comment.children.empty?
  }
end
```

Отмечу несколько тонких моментов. В серверной реализации `mustache (0.99.4)` использование пустого массива `children` обязательно, иначе
возникнет бесконечный цикл при отрисовке рекурсивного шаблона. Параметр `empty` необходим, чтобы не отрисовывать пустой список
`<ul></ul>` если нет вложенных комментариев. Этот параметр - обратная сторона logicless-природы mustache.
