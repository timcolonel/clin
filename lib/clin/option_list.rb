require 'clin'
require 'clin/option'

# Option that can be used multiple time in the command line
class Clin::OptionList < Clin::Option
  # @see Clin::Option#initialize
  def initialize(*args)
    super
    if flag?
      self.default = 0
    else
      self.default = []
    end
  end

  def on(value, out)
    if flag?
      out[@name] ||= 0
      out[@name] += 1
    else
      out[@name] ||= []
      out[@name] << value
    end
  end
end
