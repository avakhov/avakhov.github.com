---
title: Неймспейсы в Рейлс
image: /assets/namespaces.jpg
---
В Рейлс очень удобно организовывать код по неймспейсам.

Например создадим файл `app/components/api/command.rb`, со следующим содержанием:

``` ruby
# app/components/api/command.rb
class Api::Command
  # ...
end
```

Рейлс сам создаст промежуточный модуль `Api`, который в обычном руби приходится объявлять так:

``` ruby
module Api
  class Command
    # ...
  end
end
```

Как же это работает?

Каждое Рейлс приложение - это `Rails::Engine`, который при инициализации вызывает
серию хуков, один из которых устанавливает пути автозагрузки
<sup>[<i class="fa fa-external-link"></i>](https://github.com/rails/rails/blob/v4.1.6/railties/lib/rails/engine/configuration.rb#L37):

``` ruby
module Rails
  class Engine
# ...
    def paths
      @paths ||= begin
        paths = Rails::Paths::Root.new(@root)

        paths.add "app",                 eager_load: true, glob: "*"
        paths.add "app/assets",          glob: "*"
        paths.add "app/controllers",     eager_load: true
# ...
```

Строчка `paths.add "app", ..., glob: "*"` ищет все папки, которые есть в `app` (в нашем
случае это `app/components`).

Далее пути добавляются в `ActiveSupport::Dependencies` [<i class="fa fa-external-link"></i>](https://github.com/rails/rails/blob/v4.1.6/railties/lib/rails/engine.rb#L559):

``` ruby
module Rails
  class Engine < Railtie
# ...
    initializer :set_autoload_paths, before: :bootstrap_hook do
      ActiveSupport::Dependencies.autoload_paths.unshift(*_all_autoload_paths)
      ActiveSupport::Dependencies.autoload_once_paths.unshift(*_all_autoload_once_paths)
# ...
```

`ActiveSupport::Dependencies` расширяет все модули с помощью специального внутреннего модуля `ModuleConstMissing` [<i class="fa fa-external-link"></i>](https://github.com/rails/rails/blob/v4.1.6/activesupport/lib/active_support/dependencies.rb#L290):

``` ruby
module ActiveSupport #:nodoc:
  module Dependencies #:nodoc:
# ...
    def hook!
      Object.class_eval { include Loadable }
      Module.class_eval { include ModuleConstMissing }
      Exception.class_eval { include Blamable }
    end
# ...
```

`ModuleConstMissing` в свою очередь, используя `const_missing`, перехватает все обращения к неизвестным константам и загружает 
необходимые файлы [<i class="fa fa-external-link"></i>](https://github.com/rails/rails/blob/v4.1.6/activesupport/lib/active_support/dependencies.rb#L458), считая что раз в путях поиска (`app/*` в нашем примере) есть файл `api/command.rb`, то класс `Api::Command` должен находится именно там.

Ах да, модуль `Api`, с которого мы начали наш разговор, создается в методе `ActiveSupport::Dependencies#autoload_module!` [<i class="fa fa-external-link"></i>](https://github.com/rails/rails/blob/v4.1.6/activesupport/lib/active_support/dependencies.rb#L420)) при первой попытке
разрезолвить полное имя класса `Api::Command`:

``` ruby
module ActiveSupport #:nodoc:
  module Dependencies #:nodoc:
# ...
    def autoload_module!(into, const_name, qualified_name, path_suffix)
      return nil unless base_path = autoloadable_module?(path_suffix)
      mod = Module.new
      into.const_set const_name, mod
# ...
```
