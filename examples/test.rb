$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

a = [1, 2, 3, 4]
b = [7, 8, 9]
a.replace(b)

puts a.to_s