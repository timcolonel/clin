$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'


shell = Clin::Shell.new

choice = shell.choose('What?', %w(france usa italy germany))

puts 'YOu ' + choice
