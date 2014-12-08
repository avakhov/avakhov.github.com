---
title: Пару руби-мелочей
image: /assets/2-small-things.jpg
---
Накопилось пару мелочей, о которых хочу сегодня написать.

## Array#to_h

Ровно сто тысяч раз я писал примерно так:

``` ruby
ages = Hash[ users.map { |user|
  [user.name, user.age]
}]
```

Боги увидели мои страдания и послали человека с именем
[Marc-André Lafortune](https://github.com/marcandre), который добавил в транк метод `#to_h` [<i class="fa fa-external-link"></i>](https://github.com/ruby/ruby/commit/dc215dcd9f96620b7c06a25a741d13b19c2f130b)
около года назад.
Изменения появились в руби 2.1, я все время забываю, что этим уже можно и нужно пользоваться:

``` ruby
ages = users.map { |user|
  [user.name, user.age]
}.to_h
```

## Интерполяция без {}

Где-то в исходниках я увидел как выводять пид процесса

``` ruby
puts "PID: #$$"
```

"Что же это такое?" - подумал я. Я знаю только только вариант `puts "PID: #{$$}"`. Оказываетcя в руби
глобальные переменные можно интерполировать без кавычек:

``` ruby
$name = "Alexey"
puts "I'm #{$name}"   # => I'm Alexey
puts "I'm #$name"     # => I'm Alexey
``` 

:fire: :fire:
