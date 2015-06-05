$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'clin'

# Simple command Example
class SimpleCommand < Clin::Command
  arguments 'display <message>'

  option :echo, 'Echo some text'
  general_option Clin::HelpOptions

  def run
    puts @params[:message]
    puts @params[:echo]
  end
end

# Run example:
# SimpleCommand.parse('display "My Message" --echo SOME').run
# SimpleCommand.parse('').run
