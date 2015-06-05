require 'clin'

# Dispatcher mixin contains the class methods for command that need to redispatch to subcommands
module Clin::CommandMixin::Dispatcher
  extend ActiveSupport::Concern
  module ClassMethods # :nodoc:
    attr_accessor :_redispatch_args

    # Redispatch the command to a sub command with the given arguments
    # @param args [Array<String>|String] New argument to parse
    # @param prefix [String] Prefix to add to the beginning of the command
    # @param commands [Array<Clin::Command.class>] Commands that will be tried against
    # If no commands are given it will look for Clin::Command in the class namespace
    # e.g. If those 2 classes are defined.
    # `MyDispatcher < Clin::Command` and `MyDispatcher::ChildCommand < Clin::Command`
    # Will test against ChildCommand
    def dispatch(args, prefix: nil, commands: nil)
      @_redispatch_args = [[*args], prefix, commands]
    end

    def redispatch?
      !@_redispatch_args.nil?
    end

    def dispatch_doc(opts)
      return if _redispatch_args.nil?
      opts.separator 'Examples: '
      commands = (_redispatch_args[2] || default_commands)
      commands.each do |cmd_cls|
        opts.separator "\t#{cmd_cls.usage}"
      end
    end
  end
end
