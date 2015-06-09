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

  LONG_OPTION_REGEX = /\A(?<name>--[^=]*)(?:=(?<value>.*))?/m
  SHORT_OPTION_REGEX = /\A(?<name>-.)(?<value>(=).*|.+)?/m

  def parse_options(argv)
    arguments = []
    while (arg = argv.shift)
      case arg
      when LONG_OPTION_REGEX
        name = Regexp.last_match[:name]
        value = Regexp.last_match[:value]
        option = @command.find_by(long: name)
        parse_option(option, name, value, argv, false)
      when SHORT_OPTION_REGEX
        name = Regexp.last_match[:name]
        value = Regexp.last_match[:value]
        option = @command.find_by(short: name)
        parse_option(option, name, value, argv, true)
      else
        arguments << arg
      end
    end
    argv.replace(arguments)
    @options
  end

  def parse_option(option, name, value, argv, short)
    if option.nil?
      handle_unknown_option(name, value, argv)
      return
    end
    if option.flag?
      if value.nil?
        option.trigger(self, @options, true)
      elsif not short
        add_error Clin::OptionUnexpectedArgumentError.new(option, value)
      else
        option.trigger(self, @options, true)
        # -abc multiple flag options
        value.each_char do |s|
          option = @command.find_by(short: "-#{s}")
          if option && !option.flag?
            message = "Cannot combine short options that expect argument: #{option}"
            add_error Clin::OptionError.new(message, option)
            return
          end
          parse_option(option, "-#{s}", nil, [], true)
        end
      end
      return
    end
    if value.nil? && argv.any? && !argv.first.start_with?('-')
      value = argv.shift
    end
    if value.nil? && !option.argument_optional?
      add_error Clin::MissingOptionArgumentError.new(option)
    end
    value ||= true
    option.trigger(self, @options, value)
  end

  def handle_unknown_option(name, value, argv)
    unless @command.skip_options?
      add_error Clin::UnknownOptionError.new(name)
      return
    end
    if value.nil? && argv.any? && !argv.first.start_with?('-')
      value = argv.shift
    end
    @skipped_options += [name, value]
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

  def errors
    @errors
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
