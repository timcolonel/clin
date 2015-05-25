require 'clin'
require 'clin/option'

# Template class for reusable options and commands
# It provide the method to add options to a command
class Clin::CommandOptions
  class_attribute :options

  class_attribute :general_options

  self.options = []
  self.general_options = []
  # Add an option
  # @param args list of arguments.
  #   * First argument must be the name if no block is given.
  #     It will set automaticaly read the value into the hash with  +name+ as key
  #   * The remaining arguments are OptionsParser#on arguments
  # ```
  #   option :require, '-r', '--require [LIBRARY]', 'Require the library'
  #   option '-h', '--helper', 'Show the help' do
  #     puts opts
  #     exit
  #   end
  # ```
  def self.option(*args, &block)
    add_option Clin::Option.new(*args, &block)
  end

  def self.add_option(option)
    # Need to use += instead of << otherwise the parent class will also be changed
    self.options += [option]
  end

  def self.general_option(option)
    self.general_options += [option]
  end

  # To be called inside OptionParser block
  # @param opts [OptionParser]
  # @param out [Hash] Where the options shall be extracted
  def self.extract_options(opts, out)
    options.each do |option|
      option.extract(opts, out)
    end

    general_options.each do |option|
      option.extract_options(opts, out)
    end
  end
end
