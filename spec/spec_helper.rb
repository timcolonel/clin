require 'coveralls'
Coveralls.wear!
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'faker'
require 'clin'

RSpec.configure do |config|

  config.order = 'random'

end
