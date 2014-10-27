---
title: Лок на запись
image: /assets/record-lock.jpg
---
Бывает, что при обновлении записи в базе приходится сделать серию сложных операций с зависимыми записями и желательно, чтобы паралельные
потоки в это время не мешали.

В PostgreSQL есть замечательный способ блокировки `SELECT FOR UPDATE`, который мне как-то подсказал [Иван](http://evtuhovich.ru).
Если запустить 2 транзакции и в обеих вызвать `SELECT FOR UPDATE`, то вторая транзакция будет ожидать окончания первой.

![](/assets/record-lock/lock.png)

В Рейсл такие запросы удобно упакованы в методе `with_lock` [<i class="fa fa-external-link"></i>](http://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html#method-i-with_lock).

``` ruby
class User < ActiveRecord::Base
  def do_some_tricky_calculations
    with_lock do
      self.name = "Tricky Dude"
      # update a lot different records
      save!
    end
  end
end
```

В логах мы увидем такой же `FOR UPDATE`, как мы это делали вручную:

![](/assets/record-lock/rails.png)

Как и в любой хорошем приеме, здесь нужна мера. Если блокировать базу надолго, то производительность упадет сильно.
