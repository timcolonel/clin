require 'clin'
require 'clin/argument'
require 'shellwords'
require 'clin/common/help_options'

# Clin Command
class Clin::Command
  include Clin::CommandMixin::Core
  include Clin::CommandMixin::Dispatcher
  include Clin::CommandMixin::Options

  general_option 'Clin::HelpOptions'

  # Parse the command and initialize the command object with the parsed options
  # @param argv [Array|String] command line to parse.
  def self.parse(argv = ARGV, fallback_help: true)
    parser = Clin::CommandParser.new(self, argv, fallback_help: fallback_help)
    parser.parse
  end

  # Contains the parameters
  attr_accessor :params

  # Contains a shell object for user interaction in the command
  # @see Clin::Shell
  attr_accessor :shell

  def initialize(params = {})
    @params = params
    @shell = Clin::Shell.new
    self.class.execute_general_options(params)
  end
end
