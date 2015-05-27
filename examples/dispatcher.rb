$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class DisplayCommand < Clin::Command
  arguments 'display <message>'

  self.description = 'Display the given message'

  def run
    puts "Display: '#{params[:message]}'"
  end
end

# Simple command Example
class PrintCommand < Clin::Command
  arguments 'print <message>'

  self.description = 'Print the given message'

  def run
    puts "Print: '#{params[:message]}'"
  end
end

if __FILE__ == $PROGRAM_NAME
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
end
