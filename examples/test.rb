$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
# require 'clin'
# require 'json'
require 'readline'
# shell = Clin::Shell.new
# a = shell.select('Choose: ', ['Choice a', 'Choice b', 'Choice c'])

a = Readline.readline('What: ', true)
puts 'Sle: ' + a

puts 'Val: '
a = gets
puts a
