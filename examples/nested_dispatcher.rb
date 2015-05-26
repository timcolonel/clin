$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple dispatch Example
class DispatchCommand < Clin::Command
  self.arguments = 'you <args>...'
  dispatch :args, prefix: 'you'
  general_option Clin::HelpOptions

  self.description = 'YOU print the given message'

  def initialize(options)
    @options = options
    puts "Lol: '#{options}'"
  end
end

# Simple command Example
class DispatchCommand::DisplayCommand < Clin::Command
  self.arguments = 'you display <message>'

  general_option Clin::HelpOptions

  self.description = 'Display the given message'

  def initialize(options)
    @options = options
    puts "I Display: '#{options[:message]}'"
  end
end

# Simple command Example
class DispatchCommand::PrintCommand < Clin::Command
  self.arguments = 'you print <message>'

  general_option Clin::HelpOptions

  self.description = 'Print the given message'

  def initialize(options)
    @options = options
    puts "I Print: '#{options[:message]}'"
  end
end


Clin::CommandDispatcher.parse('you display "My Message"')
puts
puts '=' * 60
puts
Clin::CommandDispatcher.parse('you print "My Message"')
puts
puts '=' * 60
puts
begin
  Clin::CommandDispatcher.parse('you -h')
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
# I Display: 'My Message'
#
# ============================================================
#
# I Print: 'My Message'
#
# ============================================================
#
# Usage: command you <args>... [Options]
#
# Options:
#     -h, --help                       Show the help.
#
# Description:
# YOU print the given message
#
#
# ============================================================
#
# Usage:
#   command you <args>... [Options]
#   command you display <message> [Options]
#   command you print <message> [Options]