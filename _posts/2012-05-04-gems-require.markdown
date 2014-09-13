---
title: Гемы - require и bundler
old_image: /assets/7-gem/gem2.jpg
---

Мне не хватит духу написать подробное руководство как создать гем, к тому же я сам не эксперт в этом вопросе, лучше
расскажу сегодня про еще одну ошибку, на которую я потратил пару часов, дойдя даже до отладки. Она
настолько глупая, что не хочется, чтобы еще кто-то терял свое время. Точнее говоря, это даже не ошибка, а заблуждение.

В одном гемспеке я прописал зависимость от хамла:

``` ruby
### secret.gemspec
Gem::Specification.new do |gem|
  gem.authors       = ["Alexey Vakhov"]
  # ..

  gem.add_dependency 'haml'
```

Этот гем является энджином, в нем есть контроллеры и вьюхи. Все прекрасно работало на тестовом приложении, но когда я прикрутил
его к новому проекту, то хамл-вьюхи перестали подцеплятся. Я заглядывал в Gemfile.lock файл и видел зависимость от хамла, но вьюхи
не работали, не находился обработчик хамл. Так как я был совершенно уверен, что эта схема правильная, то мне пришлось потратить
довольно много времени, чтобы разобраться.

Думаю, вы уже поняли в чем была проблема. Я уже настолько привык к магии бандлера в рейлс, что не задумывался,
как это работает. Однако, когда мы используем бандлер вне рейлс, то написав гем-файл и вставив `require "bundler/setup"`
мы просто ограничиваем область видимости для `require`:

``` ruby
require "rubygems"
require "bundler/setup"

Nokorigi # => uninitialized constant Nokogiri (NameError)

# require your gems as usual (Nokorigi прописан в гем-файле)
require "nokogiri"

Nokorigi # => OK

require "unicorn" # => cannot load such file -- unicorn (LoadError)
```

Это пример взят с [официального сайта бандлера](http://gembundler.com/). Рейлс идет дальше и автоматически включает
все гемы из гем-файла (ориентируясь на енвайромент) в проект с помощью `Bundler.require`:

``` ruby
# config/application.rb чистого проекта

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end
```

Таким образом в моем проекте бандлер включил по умолчанию мой гем, но не включил хамл, так как он не был прописан в гем-файле проекта, 
а была только зависимость!
Гемспек используется при установке и в данном случае игнорируется бандлером. В тестовом приложении, на котором я разрабатывал гем,
хамл был включен в гем-файл и поэтому ошибки не было. Чтобы бы больше не попадаться в эту ловушку, во всех гемах я явно включаю
все зависимости в главном файле:

``` ruby
### secret.gemspec
Gem::Specification.new do |gem|
  gem.authors       = ["Alexey Vakhov"]
  # ..

  gem.add_dependency 'haml'
  gem.add_dependency 'modularity'
  gem.add_dependency 'nokorigi'
end

### lib/secret.rb
require 'haml'
require 'modularity'
require 'nokorigi'
require 'secret/version'
# ...
```

Практика показывает, что сначала нужно искать ошибки в своем коде, потом в фреймворке, потом в компиляторе, потом в железе, потом ... хм, в мироздании наверное :) Из сложных ситуаций, я ловил один раз крэш руби на домашнем компьютере из-за немного битой памяти. Руби - прожорливый язык и когда залезал в сбойные ячейки, то падал. Я догадался запустить мемтест, хотя никогда с таким не сталкивался. К слову сказать и сама система вела себя немного станно. 

Второй случай, может быть вы поможете в нем разобраться. Я все собираюсь запустить что-нибудь в
продакшн на JRuby с мультитредовым рейлс. В MRI пугают GIL (у-у-у-у, страшно. Не знаю что это, но похоже какая-то пакость, которая
не позволяет параллелить программу на несколько ядер) и плохими тредами. Поэтому готовлюсь заранее.

Насколько я понимаю, чтобы
ничего не шлепнулось, необходимо избегать использовать члены класса. Я обернул код из статьи [Let’s stop polluting the Thread.current hash](http://coderrr.wordpress.com/2008/04/10/lets-stop-polluting-the-threadcurrent-hash/) в
гем [thread_local_accessor](https://github.com/avakhov/thread_local_accessor), но он (хвала travis-ci) падал на руби 1.9.3-p125
(на p0 работал хорошо) на конструкции `ObjectSpace.define_finalizer Thread.current, FINALIZER`. Видимо в p125 нельзя прилеплять
финалайзер к `Thread.current` (я нахожусь на чертовско тонком льду понятий, которые очень слабо понимаю,
поэтому могу сморозить что-нибудь не то).

Я переписал код таким образом, что вроде он должен быть потоко-безопасным и
работает на всех версиях руби. Сейчас проверяю эту библиотеку на живых проектах, пока в однопоточном режиме:

``` ruby
# https://github.com/avakhov/thread_local_accessor/blob/master/lib/thread_local_accessor.rb

class Class
  def thread_local_accessor name, options = {}
    m = Module.new
    m.module_eval %{
      def #{name}
        k = ((Class === self ? self : self.class).object_id.to_s + '_#{name}').to_sym
        if Thread.current.key?(k)
          Thread.current[k]
        else
          #{options[:default].inspect}
        end
      end

      def #{name}=(val)
        k = ((Class === self ? self : self.class).object_id.to_s + '_#{name}').to_sym
        Thread.current[k] = val
      end
    }

    class_eval do
      include m
      extend m
    end
  end
end
```

Вы знаете почему падал предыдущий код и, как вы думаете, новый подход нормальный?
