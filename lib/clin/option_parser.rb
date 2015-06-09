require 'clin'

# Class that handler the option parsing part of command parsing.
# It separate the options from the arguments
class Clin::OptionParser
  LONG_OPTION_REGEX = /\A(?<name>--[^=]*)(?:=(?<value>.*))?/m
  SHORT_OPTION_REGEX = /\A(?<name>-.)(?<value>(=).*|.+)?/m

  attr_reader :arguments
  attr_reader :errors
  attr_reader :options
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

  def parse
    while parse_next
    end
    @options
  end

  # Extract the option
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

  def parse_option(option, name, value, short)
    return handle_unknown_option(name, value) if option.nil?
    return parse_flag_option(option, value, short) if option.flag?

    value = complete(value)
    if value.nil? && !option.argument_optional?
      add_error Clin::MissingOptionArgumentError.new(option)
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

  def parse_flag_option(option, value, short)
    return option.trigger(self, @options, true) if value.nil?
    unless short # Short can also have the format -abc
      add_error Clin::OptionUnexpectedArgumentError.new(option, value)
      return
    end

    option.trigger(self, @options, true)
    # The value is expected to be other flag options
    value.each_char do |s|
      option = @command.find_option_by(short: "-#{s}")
      if option && !option.flag?
        message = "Cannot combine short options that expect argument: #{option}"
        add_error Clin::OptionError.new(message, option)
        break
      end
      parse_flag_option(option, nil, true)
    end
  end

  def handle_unknown_option(name, value)
    unless @command.skip_options?
      add_error Clin::UnknownOptionError.new(name)
      return
    end
    if value.nil? && @argv.any? && !@argv.first.start_with?('-')
      value = @argv.shift
    end
    @skipped_options += [name, value]
  end

  def add_error(err)
    @errors << err
  end
end
