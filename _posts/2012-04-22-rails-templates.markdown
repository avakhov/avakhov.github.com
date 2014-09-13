---
title: Автоматизация создания нового приложения с помощью рейлс-темплейтов
---

Рейлс уже очень давно поддерживает темплейты при создании нового приложения. До недавнего времени я недооценивал мощь этого инструмента.
Сегодня я хочу расскать, как я использую темплейты сейчас и привести несколько хитростей из личной практики.

Если вы писали генераторы, то вы уже знакомы с темплейтами, так как они построены на том же коде, что и генераторы.
В любом случае вот этих 3 ссылок достаточно, чтобы узнать всю необходимую информацию:

* [http://m.onkey.org/rails-templates](http://m.onkey.org/rails-templates)
* [http://guides.rubyonrails.org/generators.html](http://guides.rubyonrails.org/generators.html)
* [http://rdoc.info/github/wycats/thor/master/Thor/Actions.html](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html)

Иван Евтухович удачно заметил на конференции, что нужная степень автоматизации, это когда все автоматизировано до безобразия.
Я абсолютно согласен с данным утверждением и стараюсь автоматизировать именно до этой степени, а иногда даже чуточку больше.

Любая автоматизация, это маленькая локальная инновация. И кроме уменьшения сроков выполнения и увеличения качества
конкретной задачи у нее есть неочевидный, но очень важный эффект - *автоматизация влияет на повседневные шаблоны
поведения программиста и на конечный результат*. Поясню на примерах. Agile кроме уменьшения сроков и увеличения
отзывчивости девелопмента помогает создавать
легкие, изящные приложения, которые не получится разработать обычными методами. Гитхаб и рубиджемс помогли нам получить
огромное количество интересного кода, который раньше не был бы открытым, даже не из-за желания скрыть свои наработки, а
из-за сложности публикации и поддержки своего опен-сорса. Гит показал нам, как здорово создавать ветки и делать маленькие комиты.
Раньше нам казалось, что ветки не нужно создавать часто, но оказывается это было не потому-что сама идея веток - бесполезна, а
потому-что сложности создания и мержа уничтожали все потенциальные приемущества. Автоматизация (как и выбор правильных
инструментов) помогает взглянуть на старые подходы к работе под другим углом, выработать и использовать новые навыки, и, в конечном
итоге, получить принципиально другой результат.

Вернемся к теме сегодняшней беседы.
В повседневной практике довольно редко приходится создавать новое приложение, обычно это приходится делать
только в начале нового проекта. Но в любом случае у каждого программиста сформирован
набор гемов и начальных настроек, которые бы он хотел использовать в любом проекте независимо от размера и назначения.
У меня тоже есть такой набор, каждый раз я его применял вручную, поэтому гем-файлы всех проектов выглядят чуть-чуть
по разному. Но вообще я всегда создавал новый проект с неохотой, потому-что нужно было добавить поддержку хамл,
спеки, удалить index.html, настроить базу и сделать еще много всяких маленьких скучных правок. Кроме того я люблю возиться
с исходниками рейлс и часто у меня возникает вопрос, как работает та или иная функциональность.
Было бы удобно иметь всегда рабочий стенд, на котором можно быстро проверять свои гипотезы. Я пробовал использовать
для этого пустой sandbox-проект, но он очень быстро приходил в негодность, плюс иногда еще хочется посмотреть как это работало 
например в 3.0 или даже в 2.3. Можно конечно еще делать так: создать пустое приложение `rails new ...`, добавить therubyracer, bundle install, настроить базу, bundle install, фух - не хватает haml, bundle install, опс - хочу автомиграции, я к ним привык - добавить, bundle install - да ну в качель эту идею и рейлс целиком, пусть работают как хотят...

Сейчас я создаю пустое приложение несколько раз за день. Так как, чтобы проверить как работает тот или иной код в чистых рейлс достаточно 3-х простых команд:

```
rails new demo-app -m <путь-до-темплейта> # у меня есть заготовки для 3.0, 3.1 и 3.2
cd demo-app
rails s   # привычное и прекрасное окружение запущено

# hack, hack, hack

cd .. && rm -fr demo-app
```

В заключение приведу свой основной темплейт-файл, который я обычно использую:

``` ruby
# Можно использовать просто команду `file`, но в этом случае
# при попытке переписать существующий файл, система спросит:
# "уверенны ли вы?" Конечно уверены! Мы же создаем проект с
# нуля и не хотим лишний раз нажимать ентер.
def file_force(name, content)
  f = File.open(name, 'w')
  f.puts content
  f.close
end

file_force 'Gemfile', <<-CODE
source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem 'pg'

gem 'haml'
gem 'jquery-rails'
gem 'unicorn'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platform => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'rails-footnotes', git: 'git://github.com/avakhov/rails-footnotes.git', branch: 'custom'
end

group :test do
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'database_cleaner'
end

group :development, :test do
  gem 'rspec-rails'
end
CODE

file_force '.gitignore', <<-CODE
/.bundle
/log/*.log
/tmp
/public/assets
CODE

file 'README.md', <<-CODE
# Project

TODO: description
CODE

file '.rspec', <<-CODE
--colour
CODE

file 'spec/spec_helper.rb', <<-CODE
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FactoryGirl::Syntax::Methods
end
CODE

file 'spec/factories.rb', <<-CODE
FactoryGirl.define do
  # factory :demo do
  #   name 'name'
  # end
end
CODE

file 'app/controllers/home_controller.rb', <<-CODE
class HomeController < ApplicationController
  def index
  end
end
CODE

file 'app/views/home/index.html.haml', <<-CODE
%h1 Home#index
%p Find me in app/views/home/index.html.haml
CODE

file 'spec/controllers/home_controller_spec.rb', <<-CODE
require 'spec_helper'

describe HomeController do
  it "index" do
    get 'index'
    response.should be_success
  end
end
CODE

# Нам не нужны примеры роутов, мы и так все знаем!
head = File.readlines('config/routes.rb').first
file_force 'config/routes.rb', <<-CODE
#{head.strip}
  root to: 'home#index'
end
CODE

# Скрипт темплейта запускается в директории
# созданного проекта:
FileUtils.rm('public/index.html')
FileUtils.rm('README.rdoc')
FileUtils.rm_rf('test')

# И мы можем запускать даже шелл-команды
system "bundle install"
system "rake db:create db:migrate db:test:prepare"
system "git init"
system "git add ."
system "git ci -amInitial"
```

После выполения этого темплейта, создается приложение с базой, с главной страницей (можно подключить
devise, которому нужен `root_path`) и зелеными спеками.
Можно вызвать команду `rails g scaffold post title:string && rake db:migrate` и экспериментировать
с моделями. Scaffold-генератор создает много файлов стоит сказать, если он нам не понравится
мы удалим его с помощью `git checkout . && git clean -df`, а может создадим чистый проект заново, с темплейтами - это просто!
