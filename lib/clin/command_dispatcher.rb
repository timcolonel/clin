require 'clin'
require 'clin/command'

# Class charge dispatching the CL to the right command
# The class can either be used directly and any of the loaded class inheriting
# from Clin::Command will be tested against.
# Otherwise you can inherit from this class to filter command
class Clin::CommandDispatcher
  class_attribute :cmds

  def self.commands=(commands)
    self.cmds = commands
  end

  def self.commands
    self.cmds ||= Clin::Command.subclasses
  end

  def self.parse(argv = ARGV)
    errors = 0
    argv = Shellwords.split(argv) if argv.is_a? String
    commands.each do |cmd|
      begin
        return cmd.parse(argv)
      rescue Clin::ArgumentError
        errors += 1
      end
    end
    fail Clin::CommandLineError, help_message
  end

  def self.help_message
    message = "Usage:\n"
    commands.each do |command|
      message << "\t#{command.usage}\n"
    end
    message
  end
end
