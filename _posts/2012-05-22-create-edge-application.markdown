---
title: Создание Edge Rails приложения
---

Если вы нашли какую-нибудь ошибку в рейлс, то нужно проверить, что ее еще не исправили в мастере.
Для этого иногда необходимо создать приложение из edge. В интернете много устаревших статей на эту тему, поэтому
сегодня расскажу, как это делаю я.

Простой способ, это сгенерировать пустое приложение на последней стабильной версии рейлс и в гемфайле
исправить запись с rails:

``` ruby
# gem 'rails', '3.2.3'
gem 'rails', path: '../rails'
```

Но обычно это не очень хорошо, так как версии библиотек, которые прописывает стабильная версия рейлс,
отличаются от тех, которые используются в мастере. Также могут измениться опции по умолчанию в различных конфигурационных
файлах. Поэтому приходится дополнительно вручную подправлять настройки.

Лучше создавать приложение прямо из edge. Для этого достаточно клонировать исходники рейлс к себе, запустить `bundle`, чтобы установить
необходимые гемы и вызвать `rails new` из исходников:

```
git clone https://github.com/rails/rails
pushd rails
  bundle
popd
./rails/railties/bin/rails new demo-app --edge
```

Опция --edge обязательная при использовании нестабильных версий рейлс, иначе приложение создатся с еще не зарелизинными версиями
библиотек и будет не рабочим.

Я уже [рассказывал](/blog/2012/04/22/rails-templates/), как я создаю новое приложение. По аналогии я создал шаблон, для
нового edge-приложения:

``` ruby
def file_force(name, content)
  f = File.open(name, 'w')
  f.puts content
  f.close
end

gem 'haml'
gem 'jquery-rails'
gem 'therubyracer', platform: :ruby, group: :assets
gem 'rails-footnotes', github: 'avakhov/rails-footnotes', branch: 'custom', group: :development
gem 'factory_girl_rails', group: :test
gem 'timecop', group: :test
gem 'database_cleaner', group: :test
gem 'rspec-rails', group: [:development, :test]

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

head = File.readlines('config/routes.rb').first
file_force 'config/routes.rb', <<-CODE
#{head.strip}
  root to: 'home#index'
end
CODE

FileUtils.rm('public/index.html')
FileUtils.rm_rf('test')

system "bundle install"
system "rake db:create db:migrate db:test:prepare"
system "git init"
system "git add ."
system "git ci -amInitial"
```

Использую шаблон с помощью команды:

```
./rails/railties/bin/rails new demo-app --edge -m rails-templates/edge-app.rb
```

По умолчанию будет использоваться рейлс из гитхаба `gem 'rails', github: 'rails/rails'`, можно поменять вручную на `gem 'rails', path: '../rails'`, чтобы экспрериментировать со своими изменениями.
