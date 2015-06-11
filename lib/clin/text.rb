require 'clin'

# Text builder class.
# Text is designed for building dynamic text that need multiple lines
# Help message and documentation are easily built with this.
# ```
# text = Clin::Text.new do
#   line 'Usage:'
#   indent 2 do
#     line 'display Message'
#     line 'print Message'
#   end
#   line 'Description: '
#   line 'This is a description', indent: 3
#   blank
#   line 'Examples:'
#   indent ' -' do
#     line 'display Message'
#     line 'print Message'
#   end
# end
# puts text # =>
# $ Usage:
#     display Message
#     print Message
#   Description:
#      This is a description
#
#   Examples:
#    -display Message
#    -print Message
#
# ```
class Clin::Text
  attr_accessor :_lines

  # All the lines added to this text will be indented with this.
  attr_accessor :global_indent

  def initialize(indent: '', &block)
    @_lines = []
    @inital_indent = compute_indent(indent)
    @global_indent = @inital_indent
    block.call(self) if block_given?
  end

  # Add a new line
  # @param text [String] line to add
  # @param indent [String|Integer] Indent the line with x spaces or the given text
  # ```
  # line('Some line')                 #=> 'Some line'
  # line('Some line', indent: 3)      #=> '   Some line'
  # line('Some line', indent: '- ')   #=> '- Some line'
  # ```
  def line(text, indent: '')
    l = process_line(text, indent: indent)
    @_lines << l
    l
  end

  # Add a line at the beginning of the text
  # @param text [String] line to add
  # @param indent [String|Integer] Indent the line with x spaces or the given text
  def prefix(text, indent: '')
    l = process_line(text, indent: indent)
    @_lines.unshift l
    l
  end

  # Add a blank line n times
  # @param times [Integer] Number of times to add the line.
  def blank(times = 1)
    @_lines += [''] * times
  end

  # Add a list of string as lines or get the existing lines.
  # @param array [Array<String>] List of lines to add.
  # @param indent [String|Integer] Indent each line. @see #line
  # @return list of lines
  def lines(array = [], indent: '')
    array.each do |l|
      line(l, indent: indent)
    end
    @_lines
  end

  # Add the content of another Clin::Text object
  # @param text [Clin::Text]
  # @param indent [String|Integer] Indent the content
  def text(text, indent: '')
    lines(text._lines, indent: indent)
  end

  # Indent all the content inside this block.
  # @param indent [String|Integer] indent value
  # @param block [Proc] Callback.
  def indent(indent, &block)
    previous_indent = @global_indent
    @global_indent += compute_indent(indent)
    block.call(self)
    @global_indent = previous_indent
  end

  # Join the lines together to form the output
  # @return [String]
  def to_s
    "#{@_lines.join("\n")}\n"
  end

  def process_line(text, indent: '')
    indent = compute_indent(indent)
    "#{global_indent}#{indent}#{text}"
  end

  def ==(other)
    return to_s == other if other.is_a? String
    return false unless other.is_a? Clin::Text
    @_lines == other._lines && @global_indent == other.global_indent
  end

  alias_method :eql?, :==

  # Process the indent.
  # If the indent is an integer it will return +indent+ spaces
  # @return [String.]
  protected def compute_indent(indent)
    indent.is_a?(Integer) ? ' ' * indent : indent
  end
end

require 'clin/text/table'
