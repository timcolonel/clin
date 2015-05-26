require 'clin'
require 'clin/option'

# Template class for reusable options and commands
# It provide the method to add options to a command
class Clin::CommandOptionsMixin
  class_attribute :options

  class_attribute :general_options
  self.options = []
  self.general_options = []


  # Add an option
  # @param args list of arguments.
  #   * First argument must be the name if no block is given.
  #     It will set automatically read the value into the hash with  +name+ as key
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

  # Add a general option
  # @param option_cls [Class<GeneralOption>] Class inherited from GeneralOption
  # @param config [Hash] General option config. Check the general option config.
  def self.general_option(option_cls, config = {})
    self.general_options += [option_cls.new(config)]
  end

  # To be called inside OptionParser block
  # Extract the option in the command line using the OptionParser and map it to the out map.
  # @param opts [OptionParser]
  # @param out [Hash] Where the options shall be extracted
  def self.register_options(opts, out)
    options.each do |option|
      option.register(opts, out)
    end

    general_options.each do |option|
      option.class.register_options(opts, out)
    end
  end
end
