$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'io/console'

s = Clin::Shell.new

a = s.password 'Pass?'

puts a
