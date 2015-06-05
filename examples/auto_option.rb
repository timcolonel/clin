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

# Run example:
# AutoOptionCommand.parse('-e "Some message 1"').run
# AutoOptionCommand.parse('--eko="Some message 2"').run
