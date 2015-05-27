$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class DisplayCommand < Clin::Command
  arguments 'display <message>'

  general_option Clin::HelpOptions

  self.description = 'Display the given message'

  def run
    puts "Display: '#{params[:message]}'"
  end
end

# Simple command Example
class PrintCommand < Clin::Command
  arguments 'print <message>'

  general_option Clin::HelpOptions

  self.description = 'Print the given message'

  def run
    puts "Print: '#{params[:message]}'"
  end
end

Clin::CommandDispatcher.parse('display "My Message"').run
puts
puts '=' * 60
puts
Clin::CommandDispatcher.parse('print "My Message"').run
puts
puts '=' * 60
puts
begin
  Clin::CommandDispatcher.parse('display -h').run
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
