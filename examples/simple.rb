$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class SimpleCommand < Clin::Command
  self.arguments = 'display <message>'

  option :echo, '-e', '--echo ECHO', 'Echo some text'

  general_option Clin::HelpOptions

  def initialize(options)
    @options = options
    puts options[:message]
    puts options[:echo]
  end
end

SimpleCommand.parse('display "My Message" --echo SOME')
puts
puts '=' * 60
puts
SimpleCommand.parse('-h')

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
