require 'clin'

# Command parser
class Clin::CommandParser
  # List of errors that have occurred during the parsing
  attr_reader :errors

  # Create the command parser
  # @param command_cls [Class<Clin::Command>] Command that must be matched
  # @param argv [Array<String>] List of CL arguments
  # @param fallback_help [Boolean] If the parse should raise an HelpError or the real error.
  def initialize(command_cls, argv = ARGV, fallback_help: true)
    @command = command_cls
    argv = Shellwords.split(argv) if argv.is_a? String
    @argv = argv
    @fallback_help = fallback_help
    @options = {}
    @arguments = {}
    @errors = []
    @skipped_options = []
  end

  def params
    out = @options.merge(@arguments)
    out[:skipped_options] = @skipped_options if @command.skip_options?
    out
  end

  def init_defaults
    @options = @command.option_defaults
  end

  # Parse the command line.
  def parse
    argv = @argv.clone
    init_defaults
    parse_options(argv)
    parse_arguments(argv)

    return redispatch(params) if @command.redispatch?
    obj = @command.new(params)
    validate!
    obj
  end

  def parse_options(argv)
    parser = Clin::OptionParser.new(@command, argv)
    @options.merge! parser.parse
    @skipped_options = parser.skipped_options
    @errors += parser.errors
    argv.replace(parser.arguments)
    @options
  end

  def add_error(err)
    @errors << err
  end

  # Parse the argument. The options must have been strip out first.
  def parse_arguments(argv)
    @command.args.each do |arg|
      value, argv = arg.parse(argv)

      @arguments[arg.name.to_sym] = value
    end
    @arguments.delete_if { |_, v| v.nil? }
    @arguments
  rescue Clin::ArgumentError => e
    add_error e
  end

  # Method called after the argument have been parsed and before creating the command
  # @param params [Array<String>] Parsed params from the command line.
  def redispatch(params)
    commands = @command._redispatch_args.last
    commands ||= @command.default_commands
    dispatcher = Clin::CommandDispatcher.new(commands)
    begin
      dispatcher.parse(redispatch_arguments(params))
    rescue Clin::HelpError
      raise Clin::HelpError, @command
    end
  end

  # Compute the list of argument to pass to the CommandDispatcher
  # @param params [Hash] Options and Arguments of the CL
  def redispatch_arguments(params)
    args, prefix = @command._redispatch_args
    args = args.map { |x| params[x] }.flatten.compact
    args = prefix.split + args unless prefix.nil?
    args += params[:skipped_options] if @command.skip_options?
    args
  end

  def valid?
    @errors.empty?
  end

  def validate!
    return if valid?
    fail Clin::HelpError, @command if @fallback_help
    fail @errors.sort_by { |e| e.class.severity }.last
  end
end
