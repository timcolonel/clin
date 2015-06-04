require 'clin'
require 'clin/command_options_mixin'
require 'clin/argument'
require 'shellwords'
require 'clin/common/help_options'

# Clin Command
class Clin::Command < Clin::CommandOptionsMixin
  class_attribute :args
  class_attribute :description

  # Redispatch will be reset to nil when inheriting a dispatcher command
  class_attribute :_redispatch_args
  class_attribute :_abstract
  class_attribute :_exe_name
  class_attribute :_skip_options

  self.args = []
  self.description = ''
  self._abstract = false
  self._skip_options = false

  # Trigger when a class inherit this class
  # Rest class_attributes that should not be shared with subclass
  # @param subclass [Clin::Command]
  def self.inherited(subclass)
    subclass._redispatch_args = nil
    subclass._abstract = false
    subclass._skip_options = false
    super
  end

  # Mark the class as abstract
  def self.abstract(value)
    self._abstract = value
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
  def self.exe_name(value = nil)
    self._exe_name = value unless value.nil?
    self._exe_name ||= Clin.exe_name
  end

  def self.skip_options(value)
    self._skip_options = value
  end

  def self.skip_options?
    _skip_options
  end

  def self.redispatch?
    !_redispatch_args.nil?
  end

  def self.arguments(args)
    self.args = []
    [*args].map(&:split).flatten.each do |arg|
      self.args += [Clin::Argument.new(arg)]
    end
  end

  def self.usage
    a = [exe_name, args.map(&:original).join(' '), '[Options]']
    a.reject(&:blank?).join(' ')
  end

  def self.banner
    "Usage: #{usage}"
  end

  # Parse the command and initialize the command object with the parsed options
  # @param argv [Array|String] command line to parse.
  def self.parse(argv = ARGV, fallback_help: true)
    parser = Clin::CommandParser.new(self, argv, fallback_help: fallback_help)
    parser.parse
  end

  # Build the Option Parser object
  # Used to parse the option
  # Useful for regenerating the help as well.
  def self.option_parser(out = {})
    OptionParser.new do |opts|
      opts.banner = banner
      opts.separator ''
      opts.separator 'Options:'
      register_options(opts, out)
      dispatch_doc(opts)
      unless description.blank?
        opts.separator "\nDescription:"
        opts.separator description
      end
      opts.separator ''
    end
  end

  # Redispatch the command to a sub command with the given arguments
  # @param args [Array<String>|String] New argument to parse
  # @param prefix [String] Prefix to add to the beginning of the command
  # @param commands [Array<Clin::Command.class>] Commands that will be tried against
  # If no commands are given it will look for Clin::Command in the class namespace
  # e.g. If those 2 classes are defined.
  # `MyDispatcher < Clin::Command` and `MyDispatcher::ChildCommand < Clin::Command`
  # Will test against ChildCommand
  def self.dispatch(args, prefix: nil, commands: nil)
    self._redispatch_args = [[*args], prefix, commands]
  end

  def self.dispatch_doc(opts)
    return if _redispatch_args.nil?
    opts.separator 'Examples: '
    commands = (_redispatch_args[2] || default_commands)
    commands.each do |cmd_cls|
      opts.separator "\t#{cmd_cls.usage}"
    end
  end

  def self.default_commands
    # self.constants.map { |c| self.const_get(c) }
    # .select { |c| c.is_a?(Class) && (c < Clin::Command) }
    subcommands
  end

  # List the subcommands
  # The subcommands are all the Classes inheriting this one that are not set to abstract
  def self.subcommands
    subclasses.reject(&:_abstract)
  end

  general_option 'Clin::HelpOptions'

  # Contains the parameters
  attr_accessor :params

  # Contains a shell object for user interaction in the command
  # @see Clin::Shell
  attr_accessor :shell

  def initialize(params = {})
    @params = params
    @shell = Clin::Shell.new
    self.class.execute_general_options(params)
  end
end
