require 'benchmark/ips'
$LOAD_PATH.push File.expand_path('../..', __FILE__)
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

Benchmark.ips do |x|
  x.report('simple') do
    require 'examples/simple'
    SimpleCommand.parse('display Some -e "Even More"')
  end

  x.report('auto_option') do
    require 'examples/auto_option'
    AutoOptionCommand.parse('--eko="Lorem ipsum"')
  end

  x.report('nested_dispatcher') do
    require 'examples/nested_dispatcher'
    DispatchCommand.parse('you display Some --verbose -e More --times 3')
  end
end
