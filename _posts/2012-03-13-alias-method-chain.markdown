---
title: Alias Method Chain
---

В ActiveSupport есть метод [`alias_method_chain`](http://api.rubyonrails.org/classes/Module.html#method-i-alias_method_chain), который позволяет удобно расширять функциональность методов.

``` ruby
class A
  def some
  end
end

class B < A
  def some_with_bench
    benchmark "some method" do
      some_without_bench
    end
  end
  alias_method_chain :some, :bench
end
```

Он также корректно обрабатывает методы, которые заканчиваются на <tt>?</tt>, <tt>!</tt> или <tt>=</tt>.
У этого метода есть 2 хитрости: одна полезная, другая для души.

## 1. Перегрузка сеттера

Если вы перегружаете сеттер-метод, мне однажды это понадобилось cделать в модели, необходимо помнить
о правильном синтаксисе:

``` ruby
class Model < ActiveRecord::Base
  def value_with_feature=(v)
    ActiveRecord::Base.logger.info "value = #{v};"
    
    value_without_feature=(v) # <-- НЕПРАВИЛЬНО! Старый метод не будет вызван!
                              # Никаких ошибок показано не будет.

    self.value_without_feature=(v)   # <-- OK
    send(:value_without_feature=, v) # <-- OK
  end
  alias_method_chain :value=, :feature
end
```

Конструкция в первом случае будет интерпретирована как локальная переменная
`value_without_feature`, которой присваивается значение `v`.

## 2. Блоковая версия `alias_method_chain`

`alias_method_chain` может принимать блок в качество параметра. Это недокументированная возможность
используется в `ActiveSupport::Deprecation`
[`active_support/deprecation/method_wrappers.rb#L13`](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/deprecation/method_wrappers.rb#L13). Для того и была [создана](https://github.com/rails/rails/commit/643571ca25bc2fcc701e6def0975f56fe10a732f).
