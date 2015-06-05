require 'clin'

# Contains the core class methods for the command mixin
module Clin::CommandMixin::Core
  extend ActiveSupport::Concern
  included do
    @_arguments = []
  end

  module ClassMethods # :nodoc:
    attr_accessor :_arguments
    attr_accessor :_description
    attr_accessor :_abstract
    attr_accessor :_exe_name
    attr_accessor :_skip_options

    # Trigger when a class inherit this class
    # Rest class_attributes that should not be shared with subclass
    # @param subclass [Clin::Command]
    def inherited(subclass)
      subclass._arguments = []
      subclass._description = ''
      subclass._abstract = false
      subclass._skip_options = false
      subclass._exe_name = @_exe_name
      super
    end

    # Mark the class as abstract
    def abstract(value)
      @_abstract = value
    end

    # Return if the current command class is abstract
    # @return [Boolean]
    def abstract?
      @_abstract
    end

    # Set or get the exe name.
    # Executable name that will be display in the usage.
    # If exe_name is not set in a class or it's parent it will use the global setting Clin.exe_name
    # @param value [String] name of the exe.
    # ```
    # class Git < Clin::Command
    #   exe_name 'git'
    #   arguments '<command> <args>...'
    # end
    # Git.usage # => git <command> <args>...
    # ```
    def exe_name(value = nil)
      @_exe_name = value unless value.nil?
      @_exe_name ||= Clin.exe_name
    end

    # Allow the current option to skip unknown options.
    # @param value [Boolean] skip or not
    def skip_options(value)
      @_skip_options = value
    end

    # Is the current command skipping options
    def skip_options?
      @_skip_options
    end

    # Set or get the arguments for the command
    # @param args [Array<String>] List of arguments to set. If nil it just return the current args.
    def arguments(args = nil)
      return @_arguments if args.nil?
      @_arguments = []
      [*args].map(&:split).flatten.each do |arg|
        @_arguments << Clin::Argument.new(arg)
      end
    end

    alias_method :args, :arguments

    # Set or get the description
    # @param desc [String] Description to set. If nil it just return the current value.
    def description(desc = nil)
      @_description = desc unless desc.nil?
      @_description
    end

    def usage
      a = [exe_name, @_arguments.map(&:original).join(' '), '[Options]']
      a.reject(&:blank?).join(' ')
    end

    def banner
      "Usage: #{usage}"
    end

    # Build the Option Parser object
    # Used to parse the option
    # Useful for regenerating the help as well.
    def option_parser(out = {})
      OptionParser.new do |opts|
        opts.banner = banner
        opts.separator ''
        opts.separator 'Options:'
        register_options(opts, out)
        dispatch_doc(opts)
        unless @description.blank?
          opts.separator "\nDescription:"
          opts.separator @description
        end
        opts.separator ''
      end
    end

    def default_commands
      # self.constants.map { |c| self.const_get(c) }
      # .select { |c| c.is_a?(Class) && (c < Clin::Command) }
      subcommands
    end

    # List the subcommands
    # The subcommands are all the Classes inheriting this one that are not set to abstract
    def subcommands
      subclasses.reject(&:abstract?)
    end
  end
end
