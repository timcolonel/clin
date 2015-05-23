class Clin::HelpOptions < Clin::CommandOptions
  option '-h', '--help', 'Show the help.' do |opts|
    puts opts
    exit
  end
end
