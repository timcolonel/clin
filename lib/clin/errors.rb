# Contains the errors for Clin
module Clin
  # Parent error class for all Clin errors
  Error = Class.new(RuntimeError)

  # Error cause by the user input(when parsing command)
  class CommandLineError < Error
    def self.severity(value = @severity)
      @severity = value
      @severity ||= 1
    end
  end

  # Error when the help needs to be shown
  class HelpError < CommandLineError
    def initialize(command)
      if command.class == Class && command < Clin::Command
        super(command.help)
        @command = command
      else
        super(command)
      end
    end
  end

  # Error when an positional argument is wrong
  ArgumentError = Class.new(CommandLineError)

  # Error when a fixed argument is not matched
  class RequiredArgumentError < ArgumentError
    severity 100

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
  class OptionError < CommandLineError
    def initialize(message, option)
      super(message)
      @option = option
    end
  end

  # Error when undefined options are found in argv
  class UnknownOptionError < OptionError
    def initialize(option)
      message = "Unknown option #{option}"
      super(message, option)
    end
  end

  # Error when a flag option has an unexpected argument
  class OptionUnexpectedArgumentError < OptionError
    def initialize(option, value)
      @value = value
      message = "Unexpected argument '#{value}' for option #{option}"
      super message, option
    end
  end

  # When a option is missing it's required argument
  class MissingOptionArgumentError < OptionError
    def initialize(option)
      message = "Missing argument for option #{option}"
      super(message, option)
    end
  end
end
