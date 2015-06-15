$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'io/console'

shell = Clin::Shell.new
100.times.each do |i|
  shell.say "# #{i}", indent: i
  sleep(0.5)
end
