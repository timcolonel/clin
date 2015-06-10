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
    indent = compute_indent(indent)
    l = "#{global_indent}#{indent}#{text}"
    @_lines << l
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

  # Process the indent.
  # If the indent is an integer it will return +indent+ spaces
  # @return [String.]
  protected def compute_indent(indent)
    indent.is_a?(Integer) ? ' ' * indent : indent
  end
end

# Table text builder
class Clin::Text::Table
  def initialize(col_delim = ' | ', row_delim: '-', outside_border: false, &block)
    @rows = []
    @header = []
    @column_length = {}
    @col_delim = col_delim
    @row_delim = row_delim
    @outside_border = outside_border
    block.call(self)
  end

  def row(*cells)
    process_columns(cells)
    @rows << cells
  end

  def header(*cells)
    process_columns(cells)
    @header = cells
  end

  def separator
    @rows << nil
  end

  def to_s
    puts @column_length
    lines = []
    lines << delimiter_row(false) if @outside_border
    if @header.any?
      line = row_to_s(@header)
      lines << line
      lines << delimiter_row
    end
    lines += @rows.map { |row| row_to_s(row) }
    lines << delimiter_row(false) if @outside_border
    "#{lines.join("\n")}\n"
  end

  def row_to_s(row)
    return delimiter_row if row.nil?
    out = []
    @column_length.size.times.each do |i|
      cell = row[i] || ''
      out << cell_to_s(cell, @column_length[i])
    end
    out = out.join(@col_delim)
    out = "#{@col_delim}#{out}#{@col_delim}" if @outside_border
    out
  end

  def cell_to_s(cell, length)
    format("%-#{length}s", cell)
  end

  def delimiter_row(inc_col_delim = true)
    line = []
    @column_length.size.times.each do |i|
      line << @row_delim * @column_length[i]
    end
    col_delim = inc_col_delim ? @col_delim : (@row_delim * @col_delim.size)
    out = line.join(col_delim)
    out = "#{@col_delim}#{out}#{@col_delim}" if @outside_border
    out
  end

  protected def process_columns(cells)
    cells.flatten!
    cells.each_with_index do |cell, i|
      @column_length[i] ||= 0
      @column_length[i] = [cell.length, @column_length[i]].max
    end
  end
end
