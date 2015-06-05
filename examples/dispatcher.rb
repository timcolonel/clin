$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class DisplayCommand < Clin::Command
  arguments 'display <message>'

  description 'Display the given message'

  def run
    puts "Display: '#{params[:message]}'"
  end
end

# Simple command Example
class PrintCommand < Clin::Command
  arguments 'print <message>'

  description 'Print the given message'

  def run
    puts "Print: '#{params[:message]}'"
  end
end

# Simple command Example
class PrintAltCommand < Clin::Command
  arguments 'print <message>'

  description 'Print the given message alternative'
  prioritize

  def run
    puts "Print alt: '#{params[:message]}'"
  end
end

# Example of run:
# Clin::CommandDispatcher.parse('display "My Message"').run
# Clin::CommandDispatcher.parse('print "My Message"').run
# Clin::CommandDispatcher.parse('display -h').run
# Clin::CommandDispatcher.parse('-h')
