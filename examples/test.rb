$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
module Mod
  extend ActiveSupport::Concern
  included do
    class_attribute :args
  end

  def print_args
    puts args.map { |x| "a: #{x}" }.to_s
  end
end
class Static
  class << self
    include Mod
  end
end

class Dynamic
  include Mod
end

Static.args = ['s args1']
Dynamic.args = ['d args1']

Static.print_args
d = Dynamic.new
d.print_args
d.args += ['s args2']
d.print_args