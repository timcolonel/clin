require 'clin'
require 'clin/command_options_mixin'
require 'clin/argument'
require 'shellwords'

# Clin Command
class Clin::Command < Clin::CommandOptionsMixin

  class_attribute :args
  class_attribute :description


  # Redispatch will be reset to nil when inheriting a dispatcher command
  class_attribute :_redispatch_args
  class_attribute :_abstract
  class_attribute :_exe_name

  self.args = []
  self.description = ''
  self._abstract = false

  # Trigger when a class inherit this class
  # Rest class_attributes that should not be shared with subclass
  # @param subclass [Clin::Command]
  def self.inherited(subclass)
    subclass._redispatch_args = nil
    subclass._abstract = false
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
  def self.exe_name(value=nil)
    self._exe_name = value unless value.nil?
    self._exe_name ||= Clin.exe_name
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
  def self.parse(argv = ARGV, raise_fixed: false)
    argv = Shellwords.split(argv) if argv.is_a? String
    argv = argv.clone
    options_map = parse_options(argv)
    error = nil
    begin
      args_map = parse_arguments(argv)
    rescue Clin::MissingArgumentError => e
      error = e
    rescue Clin::FixedArgumentError => e
      raise e if raise_fixed
      error = e
    end
    args_map ||= {}

    options = options_map.merge(args_map)
    return handle_dispatch(options) unless self._redispatch_args.nil?
    obj = new(options)
    fail error unless error.nil?
    obj
  end

  # Parse the options in the argv.
  # @return [Array] the list of argv that are not options(positional arguments)
  def self.parse_options(argv)
    out = {}
    parser = option_parser(out)
    parser.parse!(argv)
    out
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

  def self.execute_general_options(options)
    general_options.each do |gopts|
      gopts.execute(options)
    end
  end

  # Parse the argument. The options must have been strip out first.
  def self.parse_arguments(argv)
    out = {}
    self.args.each do |arg|
      value, argv = arg.parse(argv)
      out[arg.name.to_sym] = value
    end
    out.delete_if { |_, v| v.nil? }
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

  # Method called after the argument have been parsed and before creating the command
  # @param params [List<String>] Parsed params from the command line.
  def self.handle_dispatch(params)
    args, prefix, commands = self._redispatch_args
    commands ||= default_commands
    dispatcher = Clin::CommandDispatcher.new(commands)
    args = args.map { |x| params[x] }.flatten
    args = prefix.split + args unless prefix.nil?
    begin
      dispatcher.parse(args)
    rescue Clin::HelpError
      raise Clin::HelpError, option_parser
    end
  end

  def self.dispatch_doc(opts)
    return if self._redispatch_args.nil?
    opts.separator 'Examples: '
    commands = (self._redispatch_args[2] || default_commands)
    commands.each do |cmd_cls|
      opts.separator "\t#{cmd_cls.usage}"
    end
  end

  def self.default_commands
    # self.constants.map { |c| self.const_get(c) }.select { |c| c.is_a?(Class) && (c < Clin::Command) }
    self.subcommands
  end

  # List the subcommands
  # The subcommands are all the Classes inheriting this one that are not set to abstract
  def self.subcommands
    self.subclasses.reject(&:_abstract)
  end

  attr_accessor :params

  def initialize(params)
    @params = params
    self.class.execute_general_options(params)
  end
end
