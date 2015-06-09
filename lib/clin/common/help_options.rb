require 'clin'
require 'clin/general_option'

# Help option class
# Add the help option to you command
# ```
# class MyCommand < Clin::Command
#   general_option Clin::HelpOptions
# end
# ```
# Then running you command with -h or --help will show the help menu
class Clin::HelpOptions < Clin::GeneralOption
  flag_option :help, 'Show the help.' do |opts, out, _|
    out[:help] = opts
  end

  def initialize(raise: true)
    @raise = raise
  end

  def execute(options)
    return unless @raise
    fail Clin::HelpError, options[:help] if options[:help]
  end
end
