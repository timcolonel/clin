require 'clin'
require 'clin/command_options'
require 'clin/argument'
require 'shellwords'

# Clin Command
class Clin::Command < Clin::CommandOptions
  class_attribute :exe_name
  class_attribute :args
  class_attribute :description

  self.exe_name = 'command'
  self.args = []
  self.description = ''

  def self.arguments=(*args)
    args.map(&:split).flatten.each do |arg|
      self.args += [Clin::Argument.new(arg)]
    end
  end

  def self.banner
    "Usage: #{exe_name} #{args.map(&:original).join(' ')} [Options]"
  end

  # Parse the command and initialize the command object with the parsed options
  # @param argv [Array|String] command line to parse.
  def self.parse(argv = ARGV)
    argv = Shellwords.split(argv) if argv.is_a? String
    out = {}
    parser = OptionParser.new do |opts|
      opts.banner = banner
      opts.separator ''
      opts.separator 'Options:'
      extract_options(opts, out)
      opts.separator description
    end

    rem = parser.parse(argv)
    out.merge!(parse_arguments(rem))
    new(out.delete_if { |_, v| v.nil? })
  end

  # Parse the argument. The options must have been strip out first.
  def self.parse_arguments(argv)
    out = {}
    self.args.each do |arg|
      value, argv = arg.parse(argv)
      out[arg.name.to_sym] = value
    end
    out
  end
end
