---
title: Удаляем записи из базы данных
image: /assets/remove_a_lot_records.jpg
---
Если база маленькая её можно и даже, думаю, нужно, считать той штукой, которая выполняет
Active Record запросы. Когда записей уже миллионы, начинаются разные интересные задачи.

Как то раз я расщеплял базу на две и нужно было удалить примерно 10 миллионов детей,
которые остались без родителей (имена таблиц - выдуманные).

![](/assets/remove_a_lot_records/db.png)

[Иван Евтухович](http://evtuhovich.ru/) (я всегда звоню ему с техническими вопросами,
Иван знает все, особенно про PostgreSQL) сказал, что можно конечно удалить в лоб,
в одной транзакции, но она будет работать долго и молча.
Лучше положить id во временную таблицу и удалять записи небольшими порциями, не теряя лица.


## Играем с тестовой базой

Заполняем базу крайне синтетическими данными на 20M записей [<i class="fa fa-external-link"></i>](https://gist.github.com/avakhov/48518e4902acb57a7fed#file-1_seed-rb):

``` ruby
# ...
10_000.times do
  parent = Parent.create!
  values = ["(#{parent.id})"]*1000
  sql = "INSERT INTO children (parent_id) VALUES #{values.join(", ")};"
  ActiveRecord::Base.connection.execute(sql)
  puts "Parent ##{parent.id}"
end
10_000.times do |i|
  values = ["(0)"]*1000
  sql = "INSERT INTO children (parent_id) VALUES #{values.join(", ")};"
  ActiveRecord::Base.connection.execute(sql)
  puts "Chunk ##{i}"
end
```

Удаляем одним запросом:

``` sql
DELETE FROM children
WHERE id IN (
  SELECT children.id
  FROM children LEFT JOIN parents ON children.parent_id = parents.id
  WHERE parents.id IS NULL
);
-- => DELETE 10000000
-- => Time: 7538596.724 ms (~ 2 hours)
```

Удаляем порциями по 1000 записей [<i class="fa fa-external-link"></i>](https://gist.github.com/avakhov/48518e4902acb57a7fed#file-3_by_small_chunks-rb):

``` ruby
# ...
unless ActiveRecord::Base.connection.table_exists?("deleting_ids")
  m1 = Benchmark.measure {
    ActiveRecord::Base.connection.execute <<-SQL
      BEGIN;

      CREATE TABLE deleting_ids(id integer);
      CREATE INDEX ON deleting_ids(id);

      INSERT INTO deleting_ids
      SELECT children.id
      FROM children LEFT JOIN parents ON children.parent_id = parents.id
      WHERE parents.id IS NULL;

      COMMIT;
    SQL
  }
end

m2 = Benchmark.measure {
  index = 0
  while DeletingId.first
    ids = DeletingId.limit(1000).pluck(:id)
    Child.delete_all(id: ids)
    DeletingId.delete_all(id: ids)
    puts "Chunk ##{index += 1} processed"
  end
}
# => (112.227890)   (~ 2 mins)
# => (1052.880441)  (~ 17 mins)
```

## Выводы

В одной транзакции 10М записей удалялось 2 часа,
по частям - 20 минут (эти времена некорректно сравнивать, так как многое зависит
от настроек базы, данных, нагрузки и так далее).

Даже не обращая внимание на время исполнения, второй способ все равно гораздо
лучше, так как он явно показывает прогресс и изменяет базу небольшими, контролируемыми шагами.
Более того, скрипт можно прервать в любом месте и запустить заново, он просто продолжит
удалять, что в случае одной транзакции сделать невозможно.
