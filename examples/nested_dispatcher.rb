$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple dispatch Example
class DispatchCommand < Clin::Command
  arguments 'you <args>...'
  dispatch :args, prefix: 'you'
  skip_options true

  flag_option :verbose, 'Verbose the output'

  description 'YOU print the given message'

  def run
    puts 'Should not be called'
  end
end

# Simple command Example
class DisplayCommand < DispatchCommand
  arguments 'you display <message>'
  option :echo, 'Display more text'
  option :times, 'Display the text multiple times', type: Integer

  description 'Display the given message'

  def run
    puts "I Display: '#{params[:message]}'"
  end
end

# Simple command Example
class PrintCommand < DispatchCommand
  arguments 'you print <message>'

  description 'Print the given message'

  def run
    puts "I Print: '#{params[:message]}'"
  end
end

# Example of run:
# Clin::CommandDispatcher.parse('you display "My Message"').run
# Clin::CommandDispatcher.parse('you print "My Message"').run
# Clin::CommandDispatcher.parse('you -h').run
# Clin::CommandDispatcher.parse('-h')
