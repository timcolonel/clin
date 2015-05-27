require 'clin'

# Command parser
class Clin::CommandParser
  # Create the command parser
  # @param command_cls [Class<Clin::Command>] Command that must be matched
  # @param argv [Array<String>] List of CL arguments
  # @param fallback_help [Boolean] If the parse should raise an HelpError or the real error.
  def initialize(command_cls, argv = ARGV, fallback_help: true)
    @command = command_cls
    argv = Shellwords.split(argv) if argv.is_a? String
    @argv = argv
    @fallback_help = fallback_help
  end

  # Parse the command line.
  def parse
    argv = @argv.clone
    error = nil
    options = {}
    begin
      options.merge! parse_options(argv)
    rescue Clin::OptionError => e
      error = e
    end
    begin
      options.merge! parse_arguments(argv)
    rescue Clin::ArgumentError => e
      raise e unless @fallback_help
      error = e
    end

    return redispatch(options) if @command.redispatch?
    obj = @command.new(options)
    handle_error(error)
    obj
  end

  # Parse the options in the argv.
  # @return [Array] the list of argv that are not options(positional arguments)
  def parse_options(argv)
    out = {}
    parser = @command.option_parser(out)
    skipped = skipped_options
    argv.reject! { |x| skipped.include?(x) }
    begin
      parser.parse!(argv)
    rescue OptionParser::InvalidOption => e
      raise Clin::OptionError, e.to_s
    end
    out[:skipped_options] = skipped if @command.skip_options?
    out
  end

  # Get the options that have been skipped by options_first!
  def skipped_options
    return [] unless @command.skip_options?
    argv = @argv.dup
    skipped = []
    parser = @command.option_parser
    loop do
      begin
        parser.parse!(argv)
        break
      rescue OptionParser::InvalidOption => e
        skipped << e.to_s.sub(/invalid option:\s+/, '')
        next if argv.empty? || argv.first.start_with?('-')
        skipped << argv.shift
      end
    end

    skipped
  end

  # Parse the argument. The options must have been strip out first.
  def parse_arguments(argv)
    out = {}
    @command.args.each do |arg|
      value, argv = arg.parse(argv)
      out[arg.name.to_sym] = value
    end
    out.delete_if { |_, v| v.nil? }
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
      raise Clin::HelpError, @command.option_parser
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

  def handle_error(error)
    return unless error
    fail Clin::HelpError, @command.option_parser if @fallback_help
    fail error
  end
end
