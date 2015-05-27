$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple dispatch Example
class DispatchCommand < Clin::Command
  arguments 'you <args>...'
  dispatch :args, prefix: 'you'
  skip_options true

  flag_option :verbose, 'Verbose the output'

  self.description = 'YOU print the given message'

  def run
    puts 'Should not be called'
  end
end

# Simple command Example
class DisplayCommand < DispatchCommand
  arguments 'you display <message>'
  option :echo, 'Display more text'
  option :times, 'Display the text multiple times', type: Integer

  self.description = 'Display the given message'

  def run
    puts "I Display: '#{params[:message]}'"
  end
end

# Simple command Example
class PrintCommand < DispatchCommand
  arguments 'you print <message>'

  self.description = 'Print the given message'

  def run
    puts "I Print: '#{params[:message]}'"
  end
end

if __FILE__== $0
  Clin::CommandDispatcher.parse('you display "My Message"').run
  puts
  puts '=' * 60
  puts
  Clin::CommandDispatcher.parse('you print "My Message"').run
  puts
  puts '=' * 60
  puts
  begin
    Clin::CommandDispatcher.parse('you -h').run
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