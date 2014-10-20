---
title: Мини Рейлс
image: /assets/mini-rails.jpg
---
Самое маленькое приложение на Рейлс, которое я могу написать выглядит так (проверял на 4.1.6):

``` ruby
# config.ru
require "rails"
require "action_controller/railtie"
 
class Application < Rails::Application
  routes.append do
    root to: "home#index"
  end
  config.secret_token = "s"*30
end
 
class HomeController < ActionController::Base
  def index
    render text: "Hello!"
  end
end
 
Application.initialize!
run Application
```

Создайте файл `config.ru`, с указанным выше содержанием, запустите его с помощью `rackup`.
На главной странице вы увидите "Hello!".
