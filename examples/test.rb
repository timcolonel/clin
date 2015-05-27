$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

a = [1, 2, 3]

b, c = a

puts b
puts c
