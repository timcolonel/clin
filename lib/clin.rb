require 'active_support'
require 'active_support/core_ext'
require 'optparse'
require 'clin/version'

# Clin Global module. All classes and clin modules should be inside this module
module Clin
  def self.default_exe_name
    'command'
  end

  # Global exe_name
  # If this is not override it will be 'command'
  def self.exe_name
    @exe_name ||= Clin.default_exe_name
  end

  # Set the global exe name
  def self.exe_name=(value)
    @exe_name=value
  end
end

require 'clin/command'
require 'clin/command_options_mixin'
require 'clin/general_option'
require 'clin/command_dispatcher'
require 'clin/common/help_options'
require 'clin/errors'
