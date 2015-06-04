$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

shell = Clin::Shell.new
a = []
# a << shell.choose('Is it true 1?', %w(usa france germany italy uk), allow_initials: true)
a << shell.choose('Is it true 1?', {usa: 'United states', france: 'France'}, allow_initials: true)

puts a.to_s
