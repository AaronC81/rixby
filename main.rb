require_relative './lib'
# import { all './tools' }
import { from './tools', :foo, :bar, :Person }

# This should also work
#   Tools = import './tools'
#   Tools.foo
#   Tools::SomeConstant
# (I guess this could always be returned and you just ignore it in most contexts)

puts foo
puts bar

puts Person.new('Aaron').greet
