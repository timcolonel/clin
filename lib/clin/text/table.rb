require 'clin'
require 'clin/text'

# Table text builder
class Clin::Text
  # Helper class to display tables
  class Table
    # Header row(Nil for no header)
    attr_writer :header

    # List of rows in the table
    attr_accessor :rows

    # Column delimiters
    # Can be either:
    #  * 1 string: All the column delimiter will use this.
    #  * list of string: The delimiters will be this list of string.
    #    The size must be the column size - 1
    attr_accessor :column_delimiters

    # Global Row delimiter
    # All the separator will default to this value
    attr_accessor :row_delim

    # Boolean if yes or no outside border shall be included
    attr_accessor :border

    # Column alignment. Can either be a global value(i.e. [Symbol])
    # or a column specific with an array of [Symbol]
    # * :left
    # * :center
    # * :right
    attr_accessor :alignment

    # If blank cell should be separated with the column separator.
    attr_accessor :separate_blank

    # Internal use to keep track of the column length(in characters)
    # Is a hash of column index mapping the their current length
    # @return [Hash]
    attr_accessor :column_length

    # Create a new table
    # @param col_delim [String] Set the column delimiter @see #column_delimiters
    # @param row_delim [String] Set the row delimiter @see #row_delim
    # @param border [String] Set border @see #border
    # @param align [String] Set alignment @see #align
    # @param separate_blank [Boolean] If the column separator should be added near blank cells
    # @param block [Proc] Block with self passed as param.
    def initialize(col_delim: ' | ', row_delim: '-',
                   border: true, align: :left, separate_blank: true, &block)
      @rows = []
      @header = nil
      @column_length = {}
      @column_delimiters = col_delim
      @row_delim = row_delim
      @border = border
      @separate_blank = separate_blank
      @alignment = align
      block.call(self) if block_given?
    end

    # Add a new row
    # @param cells [Array<String>] Cells.
    def row(*cells)
      @rows << TableRow.new(self, cells)
    end

    # Set or get the header row.
    # @param cells [Array<String>] Cells.
    def header(*cells)
      @header = TableRow.new(self, cells) if cells.any?
      @header
    end

    # Add a separator row
    # @param char [Char] Separator char. If nil will use the default row delimiter
    def separator(char = nil)
      @rows << TableSeparatorRow.new(self, char)
    end

    # Set or get the the column alignment
    # @param args [Array|Symbol] List of alignment.
    # ```
    # t.align :center # => All column will be centered
    # t.align :left, :center, :right #=> First column will be align left, second center, ...
    # t.align []:left, :center, :right] #=> Equivalent
    # ```
    # @see #alignment
    def align(*args)
      @alignment = sym_or_array(*args) if args.any?
      @alignment
    end

    # Set a specific column delimiter for all the column
    def column_delimiter(*args)
      @column_delimiters = sym_or_array(*args)
    end

    # Does this table render the border
    # @see #border
    # @return [Boolean]
    def border?
      @border
    end

    # Does this table separate blank cells
    # @see #separate_blank
    # @return [Boolean]
    def separate_blank?
      separate_blank
    end

    # Vertical border
    # Default '|'
    # @return [String]
    def vertical_border
      @vertical_border ||= '|'
    end

    # Build the text object for this table.
    # @return [Clin::Text]
    def to_text
      t = Clin::Text.new
      unless @header.nil?
        t.line @header.to_s
        t.line TableSeparatorRow.new(self).to_s
      end
      t.lines @rows.map(&:to_s)
      add_border(t) if border?
      t
    end

    # Build the table and get the string
    # @return [String]
    def to_s
      to_text.to_s
    end

    # Update the length of the column at +index+ with +cell_length+
    # if +cell_length+ is larger than the current value
    # @param index [Integer] Column index
    # @param cell_length [Integer] Column length in character
    def update_column_length(index, cell_length)
      @column_length[index] ||= 0
      @column_length[index] = [cell_length, @column_length[index]].max
    end

    # Get the delimiter after the column at +index+
    # Will return blank if it's the last column
    # Will handle global or specific column_delimiter values
    # @return [String]
    def delimiter_at(index)
      return '' if index >= @column_length.size - 1
      if @column_delimiters.is_a? Array
        @column_delimiters[index]
      else
        @column_delimiters
      end
    end

    # Handle arguments that can either be a symbol or an array of symbol(Potentially nested)
    # Used by attributes that accept a global value(Symbol) or a column specific value
    protected def sym_or_array(*args)
      return args if args.empty?
      args.flatten!
      args.size == 1 ? args.first : args
    end

    # Add the top and bottom border to the lines
    # @param text [Clin::Text] Text containing the rest of the table
    # @return [Clin::Text]
    protected def add_border(text)
      line = TableSeparatorRow.new(self, col_delimiter: false).to_s
      text.prefix(line)
      text.line line
      text
    end
  end

  # Table Row container class
  class TableRow
    include Enumerable

    # List of cells in the row.
    attr_accessor :cells

    # Initialize a new table row
    # @param table [Clin::Text::Table] table containing the row
    # @param cells [Array<String>]
    def initialize(table, cells)
      @table = table
      @cells = cells.flatten.each_with_index.map { |x, i| TableCell.new(table, i, x) }
    end

    # Iterate through each cells
    # @param block [Proc] take a [Clin::Table::TableCell] as argument
    def each(&block)
      @table.column_length.size.times.each do |i|
        block.call(@cells[i] || '')
      end
    end

    # If the table should render border it add the vertical border the the line
    # @param text [String] Current line
    # @param separator [String] Separate the line from the border(With a space for example)
    def border(text, separator = '')
      return text unless @table.border?
      @table.vertical_border + separator + text + separator + @table.vertical_border
    end

    # Get the delimiter to insert after the cell at +index+
    # @param index [Integer] Cell index.
    # Will return the corresponding delimiter and for the last cell will return ''
    def delimiter_at(index)
      delim = @table.delimiter_at(index)
      if !@table.separate_blank? && (@cells[index].blank? || @cells[index + 1].blank?)
        delim = ' ' * delim.size
      end
      delim
    end

    # Render the row
    # @return [String]
    def to_s
      out = ''
      each_with_index do |cell, i|
        out << cell.to_s
        out << delimiter_at(i)
      end
      border(out, ' ')
    end
  end

  # Table row that is filled with the same character
  class TableSeparatorRow < TableRow
    # Char used for separation.
    attr_accessor :char

    def initialize(table, char = nil, col_delimiter: true)
      super(table, [])
      @char = char || @table.row_delim
      @include_column_delimiter = col_delimiter
    end

    def delimiter_at(index)
      col_delim = super(index)
      @include_column_delimiter ? col_delim : (@char * col_delim.size)
    end

    def to_s
      out = ''
      each_with_index do |_, i|
        out << @char * @table.column_length[i]
        out << delimiter_at(i)
      end
      border(out, @char)
    end
  end

  # Table cell container class
  class TableCell
    def initialize(table, index, value)
      @table = table
      @index = index
      @value = value.to_s
      @table.update_column_length(index, @value.length)
    end

    # Get the length of the cell
    # @return [Integer]
    def length
      @table.column_length[@index]
    end

    def blank?
      @value.blank?
    end

    # Get the alignment for this cell
    # @return [Symbol]
    # Can be:
    # * :left
    # * :center
    # * :right
    def align
      return @table.align if @table.align.is_a? Symbol
      fail Clin::Error, 'Align must either be a symbol or an Array!' unless @table.align.is_a? Array
      @table.align[@index]
    end

    # Convert the cell to_s using the length of the column and the column alignment
    # @return [String]
    def to_s
      case align
      when :left
        @value.to_s.ljust(length)
      when :right
        @value.to_s.rjust(length)
      when :center
        @value.to_s.center(length)
      else
        fail Clin::Error, "Invalid align #{align}"
      end
    end
  end
end
