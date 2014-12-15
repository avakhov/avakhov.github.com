---
title: Сравниваем таймстемпы
image: /assets/timestamps.jpg
---

Как то раз я нашел ошибку в сервисе [Batsd](https://github.com/noahhl/batsd), написанным Noah Lorang из компании тогда еще 37signals.
И очень обрадовался, найти у ошибку у таких парней - очень почетно.

Batsd - это штука для хранения агрегированных метрик на подобии statsd, только на руби. В коде я увидел строчку,
где берутся таймстемпы из текстового файла и сравниваются как строки, без конвертации в число [<i class="fa fa-external-link"></i>](https://github.com/noahhl/batsd/blob/3cc5e016ed1424aab0fd7d7b06bad5b2076ef4ca/lib/batsd/diskstore.rb#L56-L58):

``` ruby
        File.open(filename, 'r') do |file| 
          while (line = file.gets)
            ts, value = line.split
            if ts >= start_ts && ts <= end_ts    # <--- ЗДЕСЬ!
              datapoints << {timestamp: ts.to_i, value: value.to_f}
            end
          end
          file.close
        end
```

Вот оно! - подумал я, но оказалось было рано праздновать победу. 


``` ruby
irb(main):004:0> [Time.now, Time.now.to_i]
=> [2014-12-15 13:10:19 +0300, 1418638219]

irb(main):002:0> Time.at(1_000_000_000)
=> 2001-09-09 05:46:40 +0400

irb(main):003:0> Time.at(9_999_999_999)
=> 2286-11-20 20:46:39 +0300
```

Сейчас таймстемп 10-ти значный и даты, начиная c конца 2001 года, можно безболезненно сравнивать как строки.

Это конечно хак, но хак забавный.
