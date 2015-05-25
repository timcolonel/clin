$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class DisplayCommand < Clin::Command
  self.arguments = 'display <message>'

  general_option Clin::HelpOptions

  self.description = 'Display the given message'

  def initialize(options)
    @options = options
    puts "Display: '#{options[:message]}'"
  end
end

# Simple command Example
class PrintCommand < Clin::Command
  self.arguments = 'print <message>'

  general_option Clin::HelpOptions

  self.description = 'Print the given message'

  def initialize(options)
    @options = options
    puts "Print: '#{options[:message]}'"
  end
end

Clin::CommandDispatcher.parse('display "My Message"')
puts
puts '=' * 60
puts
Clin::CommandDispatcher.parse('print "My Message"')
puts
puts '=' * 60
puts
begin
  Clin::CommandDispatcher.parse('display -h')
rescue Clin::CommandLineError => e
  puts e
end
puts
puts '=' * 60
puts
begin
  Clin::CommandDispatcher.parse('-h')
rescue Clin::CommandLineError => e
  puts e
end

# Output:
#
# $ ruby dispatcher.rb
# Display: 'My Message'
#
# ============================================================
#
# Print: 'My Message'
#
# ============================================================
#
# Usage: command display <message> [Options]
#
# Options:
#   -h, --help                       Show the help.
#
# Description:
# Display the given message
#
#
# ============================================================
#
# Usage:
#   command display <message> [Options]
#   command print <message> [Options]
