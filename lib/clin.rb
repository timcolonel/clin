require 'active_support'
require 'active_support/core_ext'
require 'optparse'
require 'clin/version'

# Clin Global module. All classes and clin modules should be inside this module
module Clin
  class << self
    # Set the global exe name. `Clin.exe_name = 'git'`
    attr_writer :exe_name

    # Set the command when comparing 2 files(Used in the shell)
    attr_writer :diff_cmd

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
  end
end

require 'clin/command'
require 'clin/command_parser'
require 'clin/command_options_mixin'
require 'clin/general_option'
require 'clin/command_dispatcher'
require 'clin/common/help_options'
require 'clin/errors'
require 'clin/option'
require 'clin/option_list'
require 'clin/shell'
