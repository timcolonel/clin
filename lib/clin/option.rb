require 'clin'

# Option container.
# Prefer the `.option`, `.flag_option`,... class methods than `.add_option Option.new(...)`
class Clin::Option
  def self.parse(name, usage, &block)
    long = nil
    short = nil
    argument = nil
    desc = []
    usage.split.each do |segment|
      if segment.start_with? '--'
        long, argument = segment.split('=', 2)
      elsif segment.start_with? '-'
        short = segment
      else
        desc << segment
      end
    end
    argument = false if argument.nil?
    new(name, desc.join(' '), short: short, long: long, argument: argument, &block)
  end

  attr_accessor :name, :description, :optional_argument, :block, :type, :default

  # Set the short name(e.g. -v for verbose)
  attr_writer :short

  # Set the long name(e.g. --verbose for verbose)
  attr_writer :long

  # Create a new option.
  # @param name [String] Option name.
  # @param description [String] Option Description.
  # @param short [String|Boolean]
  # @param long [String|Boolean]
  # @param argument [String|Boolean]
  # @param argument_optional [Boolean]
  # @param type [Class]
  # @param default [Class] If the option is not specified set the default value.
  #   If default is nil the key will not be added to the params
  # @param block [Block]
  def initialize(name, description, short: nil, long: nil,
                 argument: nil, argument_optional: false, type: nil, default: nil, &block)
    @name = name
    @description = description
    @short = short
    @long = long
    @optional_argument = argument_optional
    self.argument = argument
    @type = type
    @block = block
    @default = default
  end

  def trigger(opts, out, value)
    value = cast(value)
    if @block.nil?
      on(value, out)
    else
      block.call(opts, out, value)
    end
  end

  # Default option short name.
  # ```
  # :verbose => '-v'
  # :help => '-h'
  # :Require => '-r'
  # ```
  def default_short
    "-#{name[0].downcase}"
  end

  # Default option long name.
  # ```
  # :verbose => '--verbose'
  # :Require => '--require'
  # :add_stuff => '--add-stuff'
  # ```
  def default_long
    "--#{name.to_s.downcase.dasherize}"
  end

  # Default argument
  # ```
  # :Require => 'REQUIRE'
  # ```
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

  # Set the argument
  # @param value
  def argument=(value)
    if value
      arg = Clin::Argument.new(value)
      @optional_argument = true if arg.optional
      @argument = arg.name
    else # If false or nil
      @argument = value
    end
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

  def argument_optional?
    @optional_argument
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

  # Return array of the attributes
  def to_a
    [@name, @description, @type, short, long, argument, @optional_argument, @default, @block]
  end

  # Get the long argument syntax.
  # ```
  #  :require => '--require REQUIRE'
  # ```
  def long_argument
    return nil unless long
    out = long
    if argument
      arg = @optional_argument ? "[#{argument}]" : argument
      out += " #{arg}"
    end
    out
  end

  def banner
    args = [short, long_argument, description]
    args.compact.join(' ')
  end

  def cast(str)
    return str if type.nil?
    if type == Integer
      Integer(str)
    elsif type == Float
      Float(str)
    else
      str
    end
  end
end
