require 'coveralls'
Coveralls.wear!
$LOAD_PATH.push File.expand_path('../..', __FILE__)
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'faker'
require 'clin'

module Clin::Rspec
  module Helper

  end

  module Macro
    def suppress_puts
      before do
        allow($stdout).to receive(:puts)
      end
    end
  end
end


RSpec.configure do |config|
  config.include Clin::Rspec::Helper
  config.extend Clin::Rspec::Macro
  config.order = 'random'
end
