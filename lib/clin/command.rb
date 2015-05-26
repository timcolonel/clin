require 'clin'
require 'clin/command_options'
require 'clin/argument'
require 'shellwords'

# Clin Command
class Clin::Command < Clin::CommandOptions
  class_attribute :exe_name
  class_attribute :args
  class_attribute :description
  class_attribute :redispatch_args

  self.exe_name = 'command'
  self.args = []
  self.description = ''

  def self.arguments=(args)
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
  def self.parse(argv = ARGV)
    argv = Shellwords.split(argv) if argv.is_a? String
    argv = argv.clone
    options_map = parse_options(argv)
    error = nil
    begin
      args_map = parse_arguments(argv)
    rescue Clin::MissingArgumentError => e
      error = e
    end
    execute_general_options(options_map)
    fail error unless error.nil?
    options = options_map.merge(args_map)
    return handle_dispatch(options) unless self.redispatch_args.nil?
    new(options)
  end

  # Parse the options in the argv.
  # @return [Array] the list of argv that are not options(positional arguments)
  def self.parse_options(argv)
    out = {}
    parser = OptionParser.new do |opts|
      opts.banner = banner
      opts.separator ''
      opts.separator 'Options:'
      extract_options(opts, out)
      unless description.blank?
        opts.separator "\nDescription:"
        opts.separator description
      end
      opts.separator ''
    end
    parser.parse!(argv)
    out
  end

  def self.execute_general_options(options)
    general_options.each do |gopts|
      gopts.execute_options(options)
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
    self.redispatch_args = [[*args], prefix, commands]
  end

  # Method called after the argument have been parsed and before creating the command
  # @param params [List<String>] Parsed params from the command line.
  def self.handle_dispatch(params)
    args, prefix, commands = self.redispatch_args
    # If no commands are specified it will get the command that are in the class namespace
    commands ||= self.constants.map { |c| self.const_get(c) }.select { |c| c.is_a?(Class) && (c < Clin::Command) }
    dispatcher = Clin::CommandDispatcher.new(commands)
    args = args.map { |x| params[x] }.flatten
    args = prefix.split + args unless prefix.nil?
    dispatcher.parse(args)
  end
end
