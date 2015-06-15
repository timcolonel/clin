require 'clin'

# Command line positional argument(not option)
class Clin::Argument
  # Original name specified in the command
  attr_accessor :original

  # If the argument is optional
  attr_accessor :optional

  # If the argument accept multiple values
  attr_accessor :multiple

  # If the argument is a fixed argument(User value need to match the name)
  attr_accessor :variable

  # The name extracted without the brackets and arrows.
  # This will be the key in the params when initializing a command
  attr_accessor :name

  # Create a new argument from string
  # +argument+ will be used to deduce the name, if it's fixed, optional, accept multiple values
  # If the argument is a simple string(e.g. install) then it will be a fixed argument
  # For the argument to accept variable values it must be surrounded with <> (e.g. <command>)
  # For the argument to be optional it must be surrounded with [] (e.g. [<value>])
  # For the argument to accept multiple value it must be suffixed with ... (e.g. <commands>...)
  # @param argument [String] argument Value
  def initialize(argument)
    @original = argument
    @optional = false
    @multiple = false
    @variable = false
    argument = check_optional(argument)
    argument = check_multiple(argument)
    @name = check_variable(argument)
  end

  # Check if the argument is optional(i.e [arg])
  def check_optional(argument)
    if check_between(argument, '[', ']')
      @optional = true
      return argument[1...-1]
    end
    argument
  end

  # Check if the argument is multiple(i.e arg...)
  def check_multiple(argument)
    if argument.end_with? '...'
      @multiple = true
      return argument[0...-3]
    end
    argument
  end

  # Check if the argument is variable(i.e <arg>)
  def check_variable(argument)
    if check_between(argument, '<', '>')
      @variable = true
      return argument[1...-1]
    end
    argument
  end

  # Given a list of arguments extract the list of arguments that are matched
  def parse(argv)
    return handle_empty if argv.empty?
    if @multiple
      ensure_fixed(argv) unless @variable
      [argv, []]
    else
      ensure_fixed(argv[0]) unless @variable
      [argv[0], argv[1..-1]]
    end
  end

  protected

  # Ensure the argument are equal to the fix value
  def ensure_fixed(args)
    [*args].each do |arg|
      next if arg == @name
      fail Clin::RequiredArgumentError, @name, arg
    end
  end

  # Call when the argv is empty.
  # Will return nil, [] if the argument is optional
  # Will fail otherwise:
  # * MissingArgumentError if the argument is a variable(e.g. <arg>)
  # * FixedArgumentError if the argument is fixed(e.g. display)
  def handle_empty
    return nil, [] if optional
    if @variable
      fail Clin::MissingArgumentError, @name
    else
      fail Clin::RequiredArgumentError, @name
    end
  end

  # Check +argument+ start with +start_char+ and end with +end_char+
  # @param argument [String]
  # @param start_char [Char]
  # @param end_char [Char]
  # @return [Boolean]
  # @raise [Clin::Error] if it start but not end with.
  # ```
  #   beck_between('[arg]', '['. ']') # => true
  #   beck_between('<arg>', '<'. '>') # => true
  #   beck_between('[<arg>]', '['. ']') # => true
  #   beck_between('[<arg>]', '<'. '>') # => false
  #   beck_between('[<arg>', '<'. '>') # => raise Clin::Error
  # ```
  def check_between(argument, start_char, end_char)
    if argument[0] == start_char
      if argument[-1] != end_char
        fail Clin::Error, "Argument format error! Cannot start
                            with #{start_char} and not end with #{end_char}"
      end
      return true
    end
    false
  end
end
