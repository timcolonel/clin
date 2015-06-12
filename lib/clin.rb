require 'active_support'
require 'active_support/core_ext'
require 'readline'
require 'clin/version'

# Clin Global module. All classes and clin modules should be inside this module
module Clin
  class << self
    # Set the global exe name. `Clin.exe_name = 'git'`
    attr_writer :exe_name

    # Set the command when comparing 2 files(Used in the shell)
    attr_writer :diff_cmd

    # If the line reader should use Readline(For autocomplete and history)
    attr_writer :use_readline

    def default_exe_name
      'command'
    end

    # Global exe_name
    # If this is not override it will be 'command'
    def exe_name
      @exe_name ||= Clin.default_exe_name
    end

    def diff_cmd
      @diff_cmd ||= 'diff -u'
    end

    def use_readline?
      @use_readline ||= !ENV['CLIN_NO_READLINE']
    end
  end
end

require 'clin/command_mixin'
require 'clin/command'
require 'clin/option_parser'
require 'clin/command_parser'
require 'clin/general_option'
require 'clin/command_dispatcher'
require 'clin/common/help_options'
require 'clin/errors'
require 'clin/option'
require 'clin/option_list'
require 'clin/text'
require 'clin/shell'
require 'clin/line_reader'
