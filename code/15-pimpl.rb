require File.expand_path("../15-openstruct", __FILE__)
require 'ostruct'
require 'json'
require 'rubygems'
require 'active_support/all'
require 'active_support/json'
require 'json-schema'

module LogicComponent
  mattr_accessor :impl

  USERS_SCHEMA = {
    type: "array",
    items: {
      type: "object",
      additionalProperties: false,
      properties: {
        lname: { type: "string", required: true },
        fname: { type: "string", required: true },
        age: { type: "integer", required: false, minimum: 5, maximum: 120 }
      }
    }
  }

  class Impl
    def get_users(country)
      if country == 'Russia'
        [
          OpenStruct.new(fname: 'Alexey', lname: 'Vakhov', age: 29)
        ]
      else
        []
      end
    end
  end

  class << self
    # LogicComponent.init вызывается в инициализаторе рейлс-приложения
    def init
      self.impl = LogicComponent::Impl.new
    end

    def get_users(country)
      impl.get_users(country).tap do |out|
        JSON::Validator.validate!(USERS_SCHEMA.as_json, out.as_json)
      end
    end
  end
end

LogicComponent.init
LogicComponent.get_users("Russia").first.tap do |user|
  puts user.fname   # => "Alexey"
  puts user.lname   # => "Vakhov"
  puts user.age     # => 29
end
