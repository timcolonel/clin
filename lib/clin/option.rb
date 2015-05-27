require 'clin'

# Option container.
class Clin::Option
  attr_accessor :name, :description, :optional_argument, :block
  attr_reader :short, :long, :argument

  def initialize(name, description, short: nil, long: nil, argument: nil, optional_argument: false, &block)
    @name = name
    @description = description
    @short = short
    @long = long
    @optional_argument = optional_argument
    @argument = argument
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
    "--#{name.downcase}"
  end

  def default_argument
    name.to_s.upcase
  end

  # Get the short option
  # If @short is nil it will use #default_short
  # If @short is false it will return nil
  # @return [String]
  def short
    return nil if @short === false
    @short ||= default_short
  end

  # Get the long option
  # If @long is nil it will use #default_long
  # If @long is false it will return nil
  # @return [String]
  def long
    return nil if @long === false
    @long ||= default_long
  end

  # Get the argument option
  # If @argument is nil it will use #default_argument
  # If @argument is false it will return nil
  # @return [String]
  def argument
    return nil if @argument === false
    @argument ||= default_argument
  end

  def option_parser_arguments
    args = [short, long_argument, description]
    args.compact
  end

  def on(value, out)
    out[@name] = value
  end

  def ==(other)
    return false unless other.is_a? Clin::Option
    @name == other.name &&
        @description == other.description &&
        short == other.short &&
        long == other.long &&
        argument == other.argument &&
        @optional_argument == other.optional_argument &&
        @block == other.block
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
