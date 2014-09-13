---
title: 4 способа сказать миру привет
---

Сегодня я расскажу как сделать несколько простых http-серверов на руби, каждый из которых можно использовать
для решения тех или иных задач.

## Hello Sinatra

Самый высокоуровневый вариант. Sinatra-приложения идеально подходят для написания небольших API, простое приложение пишется
очень быстро:

``` ruby
require 'rubygems'
require 'sinatra'

set :port, 8000

get '/' do
  'Hello'
end
```

## Hallo Rack

Подавляющее большинство современных руби-фреймворков (в том числе синатра и рейлс) используют гем `rack`,
который реализует низкоуровневые http-интерфейсы.
Простой веб-сервер можно написать и на чистом rack:

``` ruby
require 'rubygems'
require 'rack'

Rack::Server.start(
  app: Proc.new{ |e|
    [200, {'Content-Type' => 'text/html'}, ['Hello']]
  },
  Port: 8000
)
```

## Salut Webrick

Слово вебрик я знаю еще со времен рейлс 1, когда я первый раз узнал про фреймворк, но для меня стало открытием,
что вебрик оказывается включен в стандартные библиотеки руби. Вот он, родной:

``` ruby
require 'webrick'

WEBrick::HTTPServer.new(:Port => 8000).tap do |server|
  server.mount_proc '/' do |req, res|
    res.body = 'Hello'
  end
  trap('INT'){ server.shutdown }
  server.start
end
```

Кстати, лог, который выдает данный скрипт, до боли знакомый:

``` text
~/proj/avakhov.github.com(1.9.3-p194)[source]$ ruby salut_webrick.rb 
[2012-12-26 10:21:52] INFO  WEBrick 1.3.1
[2012-12-26 10:21:52] INFO  ruby 1.9.3 (2012-04-20) [x86_64-darwin11.4.2]
[2012-12-26 10:21:52] INFO  WEBrick::HTTPServer#start: pid=28642 port=8000
localhost - - [26/Dec/2012:10:21:58 MSK] "GET / HTTP/1.1" 200 5
- -> /
^C[2012-12-26 10:22:05] INFO  going to shutdown ...
[2012-12-26 10:22:05] INFO  WEBrick::HTTPServer#start done.
```

## Привет TCP сервер

Как то раз я изучал проблему с сайтом, который на каждый 2-3 клик залипал на 30 секунд и отрывался по таймауту.
В чем была причина я уже не помню, однако в процессе исследований я познакомился с замечательной утилитой `tcpdump` (ничего
более похожего на Матрицу я еще пока не видел), а также запускал примитивные веб-серверы на руби. В процессе исследования кода
руби нашел еще более низкоуровневый веб сервер, чем вебрик, он уже по настоящему прекрасен:

``` ruby
require 'socket'

TCPServer.new(8000).tap do |server|
  loop do
    client = server.accept
    puts "#{client.addr[2]}"
    while line = client.gets and line !~ /^\s*$/
      puts line
    end
    puts ""

    resp = "Hello"

    headers = [
      "http/1.1 200 ok",
      "date: tue, 14 jan 1984 12:48:00 UTC+3",
      "server: Ruby TCPServer",
      "content-type: text/html; charset=utf-8",
      "content-length: #{resp.length}\r\n\r\n"].join("\r\n")
    ]
    client.write headers
    client.write resp
    client.close
  end
end
```

Если вдруг станет скучно на работе, вы всегда можете написать какой-нибудь простой http-сервер на руби, возможно это
вас развеселит. Хороших праздников!
