require 'clin'

# Class that handler the option parsing part of command parsing.
# It separate the options from the arguments
class Clin::OptionParser
  LONG_OPTION_REGEX = /\A(?<name>--[^=]*)(?:=(?<value>.*))?/m
  SHORT_OPTION_REGEX = /\A(?<name>-.)(?<value>(=).*|.+)?/m

  # List of arguments(i.e. Argv segments that are not options)
  attr_reader :arguments

  # List of errors encountered
  attr_reader :errors

  # Parsed options are store here
  attr_reader :options

  # Any option skipped(if the command allow it) will be listed in here
  attr_reader :skipped_options

  def initialize(command, argv)
    @errors = []
    @command = command
    @options = {}
    @original_argv = argv
    @argv = argv.clone
    @arguments = []
    @skipped_options = []
  end

  # Parse the argument for the command.
  # @return [Hash] return the options parsed
  # Options can also be accessed with #options
  # ```
  # # Suppose verbose and opt are defined option for the command.
  # parser = OptionParser.new(command, %w(arg1 arg2 -v --opt val))
  # parser.parse #=> {verbose: true, opt: 'val'}
  # Get the arguments
  # parser.argv # => ['arg1', 'arg2']
  # ```
  def parse
    while parse_next
    end
    @options
  end

  # Fetch the next next argument and parse the option or store it as an argument
  # @return [Boolean] true if it parsed anything, false if there are no more argument to parse
  def parse_next
    return false if @argv.empty?
    case (arg = @argv.shift)
    when LONG_OPTION_REGEX
      name = Regexp.last_match[:name]
      value = Regexp.last_match[:value]
      parse_long(name, value)
    when SHORT_OPTION_REGEX
      name = Regexp.last_match[:name]
      value = Regexp.last_match[:value]
      parse_short(name, value)
    else
      @arguments << arg
    end
    true
  end

  # Parse a long option
  # @param name [String] name of the option(--verbose)
  # @param value [String] value of the option
  # If the value is nil and the option allow argument it will try to use the next argument
  def parse_long(name, value)
    option = @command.find_option_by(long: name)
    parse_option(option, name, value, false)
  end

  # Parse a long option
  # @param name [String] name of the option(-v)
  # @param value [String] value of the option
  # If the value is nil and the option allow argument it will try to use the next argument
  def parse_short(name, value)
    option = @command.find_option_by(short: name)
    parse_option(option, name, value, true)
  end

  # Parse the given option.
  # @param option [Clin::Option]
  # @param name [String] name it was given in the command
  # @param value [String] value of the option
  # If the value is nil and the option allow argument it will try to use the next argument
  def parse_option(option, name, value, short)
    return handle_unknown_option(name, value) if option.nil?
    return parse_flag_option(option, value, short) if option.flag?

    value = complete(value)
    if value.nil? && !option.argument_optional?
      return add_error Clin::MissingOptionArgumentError.new(option)
    end
    value ||= true
    option.trigger(self, @options, value)
  end

  # Get the next possible argument in the list if the value is nil.
  # @param value [String] current option value.
  # Only get the next argument in the list if:
  # - value is nil
  # - the next argument is not an option(start with '-')
  def complete(value)
    if value.nil? && @argv.any? && !@argv.first.start_with?('-')
      @argv.shift
    else
      value
    end
  end

  # Parse a flag option(No argument)
  # Add [OptionUnexpectedArgumentError] If value is defined and the long version was used.
  # Short flag option can be merged together(i.e these are equivalent: -abc, -a -b -c)
  # In that case the value will be 'bc'. It will then try to parse b and c as flag options.
  def parse_flag_option(option, value, short)
    return option.trigger(self, @options, true) if value.nil?
    unless short # Short can also have the format -abc
      return add_error Clin::OptionUnexpectedArgumentError.new(option, value)
    end

    option.trigger(self, @options, true)
    # The value is expected to be other flag options
    parse_compact_flag_options(value)
  end

  # Parse compact flag_options(e.g. For -abc it will be called with 'bc')
  # @param options [String] List of options where each char should correspond to a short option
  def parse_compact_flag_options(options)
    options.each_char do |s|
      option = @command.find_option_by(short: "-#{s}")
      if option && !option.flag?
        message = "Cannot combine short options that expect argument: #{option}"
        add_error Clin::OptionError.new(message, option)
        break
      end
      parse_flag_option(option, nil, true)
    end
  end

  # Handle the case where the option was not defined in the command.
  # @param name [String] name used in the command.
  # @param value [String] Value of the option if applicable.
  # Add [UnknownOptionError] if the command doesn't allow unknown options.
  def handle_unknown_option(name, value)
    unless @command.skip_options?
      add_error Clin::UnknownOptionError.new(name)
      return
    end
    value = complete(value)
    @skipped_options += [name, value]
  end

  def add_error(err)
    @errors << err
  end
end
