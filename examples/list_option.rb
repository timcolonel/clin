$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'clin'

# Simple command Example
class ListCommand < Clin::Command
  list_option :echo, 'Echo some text'
  list_flag_option :line, 'Print a line in between'
  general_option Clin::HelpOptions

  def run
    @params[:echo].each do |msg|
      puts msg
      params[:line].times do
        puts
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  ListCommand.parse('--echo "Message 1" --echo "Message 2"').run
  puts
  puts '=' * 60
  puts
  ListCommand.parse('--echo "Message 3" --echo "Message 4" -ll').run
end
