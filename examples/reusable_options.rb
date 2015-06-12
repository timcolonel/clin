$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

class SourceOptions < Clin::GeneralOption
  option :source, 'Set the source'
end

class ReusableOptionCommand < Clin::Command
  flag_option :verbose, 'Verbose'
  option :echo, 'Echo'

  general_option SourceOptions

  def run
    puts params
  end
end
