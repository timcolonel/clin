require 'active_support'
require 'active_support/core_ext'
require 'optparse'
require 'clin/version'

# Clin Global module. All classes and clin modules should be inside this module
module Clin
end

require 'clin/command'
require 'clin/command_options_mixin'
require 'clin/general_option'
require 'clin/command_dispatcher'
require 'clin/common/help_options'
require 'clin/errors'
