$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
require 'json'

def decode(str)
  str.gsub(/([^\\](?:\\\\)*\\u[\da-f]{4})/i) do |m|
    m[0...-6] + [m[-4..-1].to_i(16)].pack('U')
  end
end

a = []
a << decode('1 This string does not have a unicode \\u escape.')
a << decode('2 This string does not have a unicode \u005Cu escape.')
a << decode('3 This string does not have a unicode \\\\u0075 escape.')
a << decode('4 This string does not have a unicode \\\\\\u0075 escape.')
a << JSON.parse('{"name": "This string does not have a unicode \\\\u0075 escape."}')
a << JSON.parse('{"name": "This string does not have a unicode \\\\\\u0075 escape."}')
a << JSON.parse(%({"value": #{'"some val \\a"'}}))['value']
puts a
