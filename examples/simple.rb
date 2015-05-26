$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'clin'

# Simple command Example
class SimpleCommand < Clin::Command
  arguments  'display <message>'

  option :echo, '-e', '--echo ECHO', 'Echo some text'
  general_option Clin::HelpOptions

  def run
    puts @params[:message]
    puts @params[:echo]
  end
end

SimpleCommand.parse('display "My Message" --echo SOME').run
puts
puts '=' * 60
puts
SimpleCommand.parse('-h').run

# $ ruby simple.rb
# My Message
# SOME
#
# ============================================================
#
#   Usage: command display <message> [Options]
#
# Options:
#   -e, --echo ECHO                  Echo some text
# -h, --help                       Show the help.
