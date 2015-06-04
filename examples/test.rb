$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'


class Test

  def foo
    'foo'
  end

  private def bar
    'bar'
  end

  def pub
    'pub'
  end
end


t = Test.new
puts t.foo
puts t.pub
puts t.bar
