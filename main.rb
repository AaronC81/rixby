require_relative './lib'
import './tools' => [:foo, :bar] do end

# This should also work
#   Tools = import './tools'
#   Tools.foo
#   Tools::SomeConstant
# (I guess this could always be returned and you just ignore it in most contexts)

puts foo
puts bar
