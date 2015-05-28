# Contains the errors for Clin
module Clin
  # Parent error class for all Clin errors
  Error = Class.new(RuntimeError)

  # Error cause by the user input(when parsing command)
  CommandLineError = Class.new(Error)

  # Error when the help needs to be shown
  HelpError = Class.new(CommandLineError)

  # Error when an positional argument is wrong
  ArgumentError = Class.new(CommandLineError)

  # Error when a fixed argument is not matched
  class FixedArgumentError < ArgumentError
    # Create a new FixedArgumentError
    # @param argument [String] Name of the fixed argument
    # @param got [String] What argument was in place of the fixed argument
    def initialize(argument = '', got = '')
      super("Expecting '#{argument}' but got '#{got}'")
    end
  end

  # Error when a command is missing an argument
  class MissingArgumentError < ArgumentError
    # Create a new MissingArgumentError
    # @param argument [String] Name of the missing argument
    def initialize(argument = '')
      super("Missing argument #{argument}")
    end
  end

  # Error when a option is wrong
  OptionError = Class.new(CommandLineError)
end
