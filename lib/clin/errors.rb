# Contains the errors for Clin
module Clin
  # Parent error class for all Clin errors
  Error = Class.new(RuntimeError)

  # Error cause by the user input(when parsing command)
  CommandLineError = Class.new(Error)

  # Error when an positional argument is wrong
  ArgumentError = Class.new(CommandLineError)

  # Error when a fixed argument is not matched
  FixedArgumentError = Class.new(ArgumentError)

  # Error when a command is missing an argument
  class MissingArgumentError < ArgumentError
    def to_s
      "Missing argument #{message}"
    end
  end

  # Error when a option is wrong
  OptionError = Class.new(CommandLineError)
end
