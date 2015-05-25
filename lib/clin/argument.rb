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

  def check_optional(argument)
    if argument[0] == '['
      if argument[-1] != ']'
        fail Clin::Error, 'Argument format error! Cannot start with [ and not end with ]'
      end
      @optional = true
      return argument[1...-1]
    end
    argument
  end

  def check_multiple(argument)
    if argument.end_with? '...'
      @multiple = true
      return argument[0...-3]
    end
    argument
  end

  def check_variable(argument)
    if argument[0] == '<'
      if argument[-1] != '>'
        fail Clin::Error, 'Argument format error! Cannot start with < and not end with >'
      end
      @variable = true
      return argument[1...-1]
    end
    argument
  end

  # Given a list of arguments extract the list of arguments that are matched
  def parse(argv)
    return handle_empty if argv.empty?
    if @multiple
      ensure_name(argv) unless @variable
      [argv, []]
    else
      ensure_name(argv[0]) unless @variable
      [argv[0], argv[1..-1]]
    end
  end

  private

  def ensure_name(args)
    [*args].each do |arg|
      if arg != @name
        fail Clin::FixedArgumentError, "Error expecting argument '#{arg}' to be '#{@name}'"
      end
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
end
