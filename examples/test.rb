$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'thor'
s = Thor::Shell::Basic.new
a = s.ask("What is your password?", :echo => false)

# shell = Clin::Shell.new
#
# a = shell.password('Password?')
puts a
