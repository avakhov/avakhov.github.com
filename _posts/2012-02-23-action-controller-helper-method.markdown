---
title: Action Controller Helper Method
---

Долгое время мне казалось очевидным что, для того чтобы метод контроллера объявить хелпер методом
необходимо сначала определить метод, а потом передать его имя в helper_method:

``` ruby
class ApplicationController < ActionControllerBase
  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
  helper_method :current_user
end
```
    
Однако можно объявлять метод хелпером до его конкретной имплементации.

``` ruby
class ApplicationController < ActionControllerBase
  before_filter :authenticate!
  helper_method :current_user
  # ...

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
end
```

Это более красиво выносить фильтры, хэлпер методы и другие служебные объявления в начало класса.
Я нашел эту особенность в [реализации](https://github.com/rails/rails/blob/master/actionpack/lib/abstract_controller/helpers.rb#L51) данного метода, а также есть соответствующий пример в [документации](http://api.rubyonrails.org/classes/AbstractController/Helpers/ClassMethods.html#method-i-helper_method).

Если же вернуться от рейлс к руби, то, например, метод можно сделать приватным только после его объявления:

``` ruby
class A
  private :some # <--- EXCEPTION: undefined method `some' for class `A'

  def some
    puts "some"
  end
end

class B
  def another
    puts "another"
  end

  private :another # Ok!
end
```
