$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class SimpleCommand < Clin::Command
  arguments 'display <message>'

  option :echo, 'Echo some text'
  general_option Clin::HelpOptions

  description 'Simple command that print stuff!'

  def run
    puts @params[:message]
    puts @params[:echo]
  end
end

# Run example:
# SimpleCommand.parse('display "My Message" -e SOME').run
begin
  SimpleCommand.parse('').run
rescue Clin::HelpError => e
  puts e
end
