require 'coveralls'
Coveralls.wear!
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'rspec'


RSpec.configure do |config|

  config.order = 'random'

end
