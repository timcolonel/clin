require 'clin'

# Parent class for reusable options across commands
class Clin::GeneralOption
  include Clin::CommandMixin::Options

  def initialize(_config = {})
  end

  # It get the params the general options needs and do whatever the option is suppose to do with it.
  # Method called in the initialize of the command.
  # This allow general options to be extracted when parsing a command line
  # as well as calling the command directly in the code
  # @param _params [Hash] Params got in the command
  def execute(_params)
  end
end
