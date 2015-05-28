require 'clin'

# Option container.
class Clin::Option
  attr_accessor :name, :description, :optional_argument, :block, :type, :default
  attr_reader :short, :long, :argument

  # Create a new option.
  # @param name [String] Option name.
  # @param description [String] Option Description.
  # @param short [String|Boolean]
  # @param long [String|Boolean]
  # @param argument [String|Boolean]
  # @param argument_optional [Boolean]
  # @param type [Class]
  # @param block [Block]
  def initialize(name, description, short: nil, long: nil,
                 argument: nil, argument_optional: false, type: nil, default: nil, &block)
    @name = name
    @description = description
    @short = short
    @long = long
    @optional_argument = argument_optional
    @argument = argument
    @type = type
    @block = block
    @default = default
  end

  # Register the option to the Option Parser
  # @param opts [OptionParser]
  # @param out [Hash] Out options mapping
  def register(opts, out)
    load_default(out)
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
    return nil if flag?
    @argument ||= default_argument
  end

  def option_parser_arguments
    args = [short, long_argument, @type, description]
    args.compact
  end

  # Function called by the OptionParser when the option is used
  # If no block is given this is called otherwise it call the block
  def on(value, out)
    out[@name] = value
  end

  # If the option is a flag option.
  # i.e Doesn't accept argument.
  def flag?
    @argument.eql? false
  end

  # Init the output Hash with the default values. Must be called before parsing.
  # @param out [Hash]
  def load_default(out)
    return if @default.nil?
    begin
      out[@name] = @default.clone
    rescue
      out[@name] = @default
    end
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

