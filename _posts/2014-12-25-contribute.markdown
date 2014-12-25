---
title: Пул реквесты в опен сорс
image: /assets/contribute.jpg
---
Стандартный гид по контрибьюторству, который появляется в любом свежесозданном геме, состоит
из пяти пунктов:

1. Fork it ( https://github.com/[my-github-username]/awesome-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Я расскажу пару хитростей, которые можно использовать,
чтобы сделать процесс создания пул реквестов еще приятнее и
беззаботнее.

## Процесс создания пул реквестов

_1. Форкаем репозитарий и клонируем_

```
git clone git@github.com:avakhov/awesome-gem.git
```

_2. Подцепляем оригинальный remote (я его называю papa)_

```
git remote add papa git@github.com:awesome/awesome-gem.git
```

_3. Берем самую свежую версию_

```
git fetch papa
get checkout papa/master
```

_4. Создаем ветку (можно начинать имя с чисел по порядку)_

```
git checkout -b 2-mega-fix
git push origin 2-mega-fix -u
```

_5. Комитим_

```
git commit -m"Msg"
git push
```

_6. Посылаем пул реквест через Github!_ :beer: :beer: :beer:

Переходим к пункту 3, чтобы создать новый пул реквест.

Такой процедуры легко придерживаться и она гарантирует, что мы всегда
работаем с актуальным кодом (в оригинальном процесс легко форкнуться от устаревшей ревизии).
