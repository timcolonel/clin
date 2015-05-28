require 'clin'
require 'clin/command'

# Class charge dispatching the CL to the right command
class Clin::CommandDispatcher
  # Contains the list of commands the dispatch will test.
  attr_accessor :commands

  # Create a new command dispatcher.
  # @param commands [Array<Clin::Command.class>] List of commands that can be dispatched.
  #   If commands is nil it will get all the subclass of Clin::Command loaded.
  def initialize(*commands)
    @commands = commands.empty? ? Clin::Command.subcommands : commands.flatten
  end

  # Parse the command line using the given arguments
  # It will return the newly initialized command with the arguments if there is a match
  # Otherwise will fail and display the help message
  # @param argv [Array<String>] Arguments
  # @return [Clin::Command]
  def parse(argv = ARGV)
    errors = 0
    argv = Shellwords.split(argv) if argv.is_a? String
    @commands.each do |cmd|
      begin
        return cmd.parse(argv, fallback_help: false)
      rescue Clin::ArgumentError
        errors += 1
      end
    end
    fail Clin::HelpError, help_message
  end

  # Helper method to parse against all the commands
  # @see #parse
  def self.parse(argv = ARGV)
    Clin::CommandDispatcher.new.parse(argv)
  end

  # Generate the help message for this dispatcher
  # @return [String]
  def help_message
    message = "Usage:\n"
    commands.each do |command|
      message << "\t#{command.usage}\n"
    end
    message
  end
end
