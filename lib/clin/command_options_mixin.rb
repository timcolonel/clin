require 'clin'
require 'clin/option'
require 'clin/option_list'

# Template class for reusable options and commands
# It provide the method to add options to a command
class Clin::CommandOptionsMixin
  class_attribute :options
  class_attribute :general_options
  self.options = []
  self.general_options = {}

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
  def self.opt_option(*args, &block)
    add_option Clin::Option.new(*args, &block)
  end

  # Add an option.
  # Helper method that just create a new Clin::Option with the argument then call add_option
  # ```
  #   option :show, 'Show some message'
  #   # => -s --show              SHOW Show some message
  #   option :require, 'Require a library', short: false, optional: true, argument: 'LIBRARY'
  #   # => --require [LIBRARY]    Require a library
  #   option :help, 'Show the help', argument: false do
  #     puts opts
  #     exit
  #   end
  #   # => -h --help              Show the help
  # ```
  def self.option(name, description, **config, &block)
    add_option Clin::Option.new(name, description, **config, &block)
  end

  # For an option that does not have an argument
  # Same as .option except it will default argument to false
  # ```
  #   option :verbose, 'Use verbose' #=> -v --verbose will be added to the option of this command
  # ```
  def self.flag_option(name, description, **config, &block)
    add_option Clin::Option.new(name, description, **config.merge(argument: false), &block)
  end

  # Add a list option.
  # @see Clin::OptionList#initialize
  def self.list_option(name, description, **config)
    add_option Clin::OptionList.new(name, description, **config)
  end

  # Add a list options that don't take arguments
  # Same as .list_option but set +argument+ to false
  # @see Clin::OptionList#initialize
  def self.list_flag_option(name, description, **config)
    add_option Clin::OptionList.new(name, description, **config.merge(argument: false))
  end

  # Add a new option.
  # @param option [Clin::Option] option to add.
  def self.add_option(option)
    # Need to use += instead of << otherwise the parent class will also be changed
    self.options += [option]
  end

  # Add a general option
  # @param option_cls [Class<GeneralOption>] Class inherited from GeneralOption
  # @param config [Hash] General option config. Check the general option config.
  def self.general_option(option_cls, config = {})
    option_cls = option_cls.constantize if option_cls.is_a? String
    self.general_options = general_options.merge(option_cls => option_cls.new(config))
  end

  # Remove a general option
  # Might be useful if a parent added the option but is not needed in this child.
  def self.remove_general_option(option_cls)
    option_cls = option_cls.constantize if option_cls.is_a? String
    self.general_options = general_options.except(option_cls)
  end

  # To be called inside OptionParser block
  # Extract the option in the command line using the OptionParser and map it to the out map.
  # @param opts [OptionParser]
  # @param out [Hash] Where the options shall be extracted
  def self.register_options(opts, out)
    options.each do |option|
      option.register(opts, out)
    end

    general_options.each do |_cls, option|
      option.class.register_options(opts, out)
    end
  end

  # Call #execute on each of the general options.
  # This is called during the command initialization
  # e.g. A verbose general option execute would be:
  # ```
  # def execute(params)
  #  MyApp.verbose = true if params[:verbose]
  # end
  # ```
  def self.execute_general_options(options)
    general_options.each do |_cls, gopts|
      gopts.execute(options)
    end
  end
end
