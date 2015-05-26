require 'coveralls'
Coveralls.wear!
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'faker'
require 'clin'

module Clin::Rspec
  module Helper
  end
end

RSpec.configure do |config|
  config.include Clin::Rspec::Helper
  config.order = 'random'
end
