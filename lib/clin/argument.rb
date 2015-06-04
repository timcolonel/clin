require 'clin'

# Command line positional argument(not option)
class Clin::Argument
  attr_accessor :original
  attr_accessor :optional
  attr_accessor :multiple
  attr_accessor :variable
  attr_accessor :name

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
      fail Clin::FixedArgumentError, @name, arg
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
      fail Clin::FixedArgumentError, @name
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
