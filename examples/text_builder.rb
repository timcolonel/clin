$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'
values = ['Some value 1', 'Some value 2']
text = Clin::Text.new do |t|
  t.line 'Usage:'
  t.indent 2 do
    t.line 'display Message'
    t.line 'print Message'

    t.indent 3 do
      t.line '--echo'
      t.line '--verbose'
    end
  end
  t.line 'Description: '
  t.line 'This is a description', indent: 3
  t.blank
  t.line 'Examples:'
  t.indent ' -' do
    t.line 'display Message'
    t.line 'print Message'
  end
  t.line 'Values: '
  t.lines values, indent: '*** '
end
puts text

table = Clin::Text::Table.new(border: true) do |t|
  t.align :right, :center, :left
  # t.column_delimiter ' - ', ' # '
  t.header %w(First Last Email)

  t.row %w(Timothee Guerin timothee.guerin@outlook.com)
  t.row %w(Some Guy Some.Guy@outlook.com)

  t.separator

  t.row %w(VeryLongFirstName Guy Some.Other@outlook.com)
end
puts table
