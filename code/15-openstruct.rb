require 'ostruct'
require 'json'
require 'rubygems'
require 'active_support/all'

class OpenStruct
  def as_json
    marshal_dump.as_json
  end
  
  def to_json
    marshal_dump.to_json
  end

  def to_s
    marshal_dump.to_s
  end

  def inspect
    to_s
  end
end

# p OpenStruct.new(a: 3, b: [1, 2]).to_json
# p OpenStruct.new(a: 3, b: [1, 2]).as_json
# p OpenStruct.new(a: 3, b: [1, 2]).inspect
# 
# p ({a: 3, b: [1, 2]}).to_json
# p ({a: 3, b: [1, 2]}).as_json
# p ({a: 3, b: [1, 2]}).inspect
