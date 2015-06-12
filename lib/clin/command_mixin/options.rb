require 'clin'
require 'clin/option'

# Contains class methods to add option to a command or a General option
module Clin::CommandMixin::Options
  extend ActiveSupport::Concern

  included do
    self.specific_options = []
    self.general_options = {}
    # Trigger when a class inherit this class
    # It will clone attributes that need inheritance
    # @param subclass [Clin::Command]
    def self.inherited(subclass)
      subclass.specific_options = @specific_options.clone
      subclass.general_options = @general_options.clone
      super
    end
  end

  module ClassMethods # :nodoc:
    attr_accessor :specific_options
    attr_accessor :general_options

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
    def option(name, description, **config, &block)
      add_option Clin::Option.new(name, description, **config, &block)
    end

    # For an option that does not have an argument
    # Same as .option except it will default argument to false
    # ```
    #   option :verbose, 'Use verbose' #=> -v --verbose will be added to the option of this command
    # ```
    def flag_option(name, description, **config, &block)
      add_option Clin::Option.new(name, description, **config.merge(argument: false), &block)
    end

    # Add a list option.
    # @see Clin::OptionList#initialize
    def list_option(name, description, **config)
      add_option Clin::OptionList.new(name, description, **config)
    end

    # Add a list options that don't take arguments
    # Same as .list_option but set +argument+ to false
    # @see Clin::OptionList#initialize
    def list_flag_option(name, description, **config)
      add_option Clin::OptionList.new(name, description, **config.merge(argument: false))
    end

    def auto_option(name, usage, &block)
      add_option Clin::Option.parse(name, usage, &block)
    end

    # Add a new option.
    # @param option [Clin::Option] option to add.
    def add_option(option)
      # Need to use += instead of << otherwise the parent class will also be changed
      @specific_options << option
    end

    # Add a general option
    # @param option_cls [Class<GeneralOption>] Class inherited from GeneralOption
    # @param config [Hash] General option config. Check the general option config.
    def general_option(option_cls, config = {})
      option_cls = option_cls.constantize if option_cls.is_a? String
      @general_options[option_cls] = option_cls.new(config)
    end

    # Remove a general option
    # Might be useful if a parent added the option but is not needed in this child.
    def remove_general_option(option_cls)
      option_cls = option_cls.constantize if option_cls.is_a? String
      @general_options.delete(option_cls)
    end

    # To be called inside OptionParser block
    # Extract the option in the command line using the OptionParser and map it to the out map.
    # @return [Hash] Where the options shall be extracted
    def option_defaults
      out = {}
      @specific_options.each do |option|
        option.load_default(out)
      end

      @general_options.each do |_cls, option|
        out.merge! option.class.option_defaults
      end
      out
    end

    # Call #execute on each of the general options.
    # This is called during the command initialization
    # e.g. A verbose general option execute would be:
    # ```
    # def execute(params)
    #  MyApp.verbose = true if params[:verbose]
    # end
    # ```
    def execute_general_options(options)
      general_options.each do |_cls, gopts|
        gopts.execute(options)
      end
    end

    # Return all options
    def options
      specific_options + general_options.keys.map(&:options).flatten
    end

    def find_option(value)
      find_option_by(name: value)
    end

    def find_option_by(hash)
      key, value = hash.first
      options.find { |x| x.send(key) == value }
    end

    def option_help
      Clin::Text.new do |t|
        options.each do |option|
          t.line option.banner
        end

        general_options.each do |cls, _|
          t.text cls.option_help
        end
      end
    end
  end
end
