require 'clin'
require 'clin/line_reader'
require 'io/console'

# Basic line scanner.
# Use stdin#gets
class Clin::LineReader::Basic
  attr_reader :statement
  attr_reader :options

  def self.available?
    true
  end

  def initialize(shell, statement, options = {})
    @shell = shell
    @statement = statement
    @options = options
  end

  def readline
    @shell.out.print(@statement)
    scan
  end

  protected def scan
    return @shell.in.gets if echo?
    begin
      @shell.in.noecho(&:gets)
    rescue Errno::EBADF # If console doesn't support noecho
      @shell.in.gets
    end
  end

  protected def echo?
    @options.fetch(:echo, true)
  end
end
