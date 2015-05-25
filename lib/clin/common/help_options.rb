# Help option class
# Add the help option to you command
# ```
# class MyCommand < Clin::Command
#   general_option Clin::HelpOptions
# end
# ```
# Then running you command with -h or --help will show the help menu
class Clin::HelpOptions < Clin::CommandOptions
  option '-h', '--help', 'Show the help.' do |opts, out, _|
    out[:help] = opts
  end

  def self.execute_options(options)
    fail Clin::CommandLineError, options[:help] if options[:help]
  end
end
