require 'clin'

# Option container.
class Clin::Option
  attr_accessor :name
  attr_accessor :args
  attr_accessor :block

  def initialize(*args, &block)
    if block.nil?
      name = args.shift
    else
      name = nil
    end
    @name = name
    @args = args
    @block = block
  end

  # Register the option to the Option Parser
  # @param opts [OptionParser]
  # @param out [Hash] Out options mapping
  def register(opts, out)
    if @block.nil?
      opts.on(*args) do |value|
        on(value, out)
      end
    else
      opts.on(*args) do |value|
        block.call(opts, out, value)
      end
    end
  end

  def on(value, out)
    out[@name] = value
  end

  def ==(other)
    return false unless other.is_a? Clin::Option
    @name == other.name && @args == other.args && @block == other.block
  end
end
