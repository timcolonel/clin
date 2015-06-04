$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'clin'

# Simple command Example
class AutoOptionCommand < Clin::Command
  auto_option :echo, '-e --eko=message Echo the message'
  general_option Clin::HelpOptions

  def run
    puts @params[:echo]
  end
end

if __FILE__ == $PROGRAM_NAME
  SimpleCommand.parse('-e "Some message 1"').run
  puts
  puts '=' * 60
  puts
  begin
    SimpleCommand.parse('--eko="Some message 2"').run
  rescue Clin::HelpError => e
    puts e
  end
end
