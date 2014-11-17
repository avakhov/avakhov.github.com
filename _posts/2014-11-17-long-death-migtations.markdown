---
title: Почему я не меняю схему и данные в одной миграции
image: /assets/long-death-migtations.jpg
---
В Рейлс есть метод `#reset_column_information`, который я больше никогда не использую.

## История

Допустим мы добавили колонку в таблицу `users` и тут же решили ее посчитать.
А пользователей у нас много, и расчеты сложны (миграция написана как предлагается в документации
[<i class="fa fa-external-link"></i>](http://api.rubyonrails.org/classes/ActiveRecord/ModelSchema/ClassMethods.html#method-i-reset_column_information)):

``` ruby
class SlowMigration < ActiveRecord::Migration
  def up
    add_column :users, :some_awesome_column, :string

    User.reset_column_information

    User.find_each do |user|
      user.some_awesome_column = ... # Сложные вычисления
    end
  end

  # ...
end
```

Далее деплоим новую версию приложения на хероку `git push heroku master`, юникорны начали перегружаться, и
следом запускаем миграции `heroku run rake db:migrate`.
Каждая миграция выполняется в отдельной транзакции, `add column` превратится в
`ALTER TABLE`. Опуская детали, процесс выполнения миграции выглядит так:

```
SQL: BEGIN      # <-- начало транзакции

== 20141112130023 SlowMigration: migrating =========================
-- add_column(:users, :some_awesome_column, :string)

# новая колонка
SQL: ALTER TABLE "users" ADD COLUMN "surname" character varying(255)

   -> 0.0024s
 
# <-- здесь мы долго обновляем всех пользователей

```

Теперь на наш свежеперезапущенные юникорны приходят пользователи, у которых мы проверяем
авторизацию `User.find...`. Чтобы работала магия ActiveRecord при первом обращении
к модели запрашивается схема таблицы `users`.
В Postgresql используется следующий запрос [<i class="fa fa-external-link"></i>](https://github.com/rails/rails/blob/v4.1.6/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb#L975):

``` sql
SELECT a.attname, format_type(a.atttypid, a.atttypmod),
  pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod
FROM pg_attribute a LEFT JOIN pg_attrdef d
  ON a.attrelid = d.adrelid AND a.attnum = d.adnum
WHERE a.attrelid = '"users"'::regclass
  AND a.attnum > 0 AND NOT a.attisdropped
  ORDER BY a.attnum
```

Запрос жутковатый, однако для нас важно то, что он будет ждать окончании транзакции, которая меняет схему таблицы `users`.

![](/assets/long-death-migtations/con.png)

Я промоделировал проблему в консоли, но рейлс приложение залипает абсолютно так же.

## Выводы

Метод `#reset_column_information` сам по себе хороший, но шаблон использования, который он
предлагает, может испортить выкатку на Хероку. Поэтому я больше не меняю схему и данные в одной транзакции.
