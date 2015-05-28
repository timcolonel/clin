require 'clin'

# Option container.
class Clin::Option
  attr_accessor :name, :description, :optional_argument, :block, :type
  attr_reader :short, :long, :argument

  def initialize(name, description, short: nil, long: nil,
                 argument: nil, argument_optional: false, type: nil, &block)
    @name = name
    @description = description
    @short = short
    @long = long
    @optional_argument = argument_optional
    @argument = argument
    @type = type
    @block = block
  end

  # Register the option to the Option Parser
  # @param opts [OptionParser]
  # @param out [Hash] Out options mapping
  def register(opts, out)
    if @block.nil?
      opts.on(*option_parser_arguments) do |value|
        on(value, out)
      end
    else
      opts.on(*option_parser_arguments) do |value|
        block.call(opts, out, value)
      end
    end
  end

  def default_short
    "-#{name[0].downcase}"
  end

  def default_long
    "--#{name.to_s.downcase.dasherize}"
  end

  def default_argument
    name.to_s.upcase
  end

  # Get the short option
  # If @short is nil it will use #default_short
  # If @short is false it will return nil
  # @return [String]
  def short
    return nil if @short.eql? false
    @short ||= default_short
  end

  # Get the long option
  # If @long is nil it will use #default_long
  # If @long is false it will return nil
  # @return [String]
  def long
    return nil if @long.eql? false
    @long ||= default_long
  end

  # Get the argument option
  # If @argument is nil it will use #default_argument
  # If @argument is false it will return nil
  # @return [String]
  def argument
    return nil if @argument.eql? false
    @argument ||= default_argument
  end

  def option_parser_arguments
    args = [short, long_argument, @type, description]
    args.compact
  end

  def on(value, out)
    out[@name] = value
  end

  def ==(other)
    return false unless other.is_a? Clin::Option
    to_a == other.to_a
  end

  def to_a
    [@name, @description, @type, short, long, argument, @optional_argument, @block]
  end

  protected

  def long_argument
    return nil unless long
    out = long
    if argument
      arg = @optional_argument ? "[#{argument}]" : argument
      out += " #{arg}"
    end
    out
  end
end
