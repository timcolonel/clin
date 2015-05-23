# Contains the errors for Clin
module Clin
  Error = Class.new(RuntimeError)
  class CommandLineError < Clin::Error
  end
end
