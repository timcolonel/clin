$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

# Simple command Example
class OptionalArgumentCommand < Clin::Command
  self.arguments = 'display [<message>]'

  def initialize(options)
    @options = options
    puts options.fetch(:message, 'No message given')
  end
end

OptionalArgumentCommand.parse('display "My Message"')
puts
puts '=' * 60
puts
OptionalArgumentCommand.parse('display')

# $ ruby optional_argument.rb
# My Message
#
# ============================================================
#
# No message given
