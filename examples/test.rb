$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

shell = Clin::Shell.new
a = []
a << shell.override?('D:/dev/test/diff.txt') do
  <<DOC
Soruju was an aircraft
carrier built for the Imperial
Japanese Navy during
the mid-1930s.
DOC
end


puts a.to_s
