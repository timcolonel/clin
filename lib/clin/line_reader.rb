require 'clin'

# Handle to delegate the scan method to the right module.
# It will use Readline unless the disabled using Clin.use_readline = false
module Clin::LineReader
  def self.scan(shell, statement, options = {})
    readers.detect(&:available?).new(shell, statement, options).readline
  end

  def self.readers
    @readers ||= [Clin::LineReader::Readline, Clin::LineReader::Basic]
  end
end

require 'clin/line_reader/basic'
require 'clin/line_reader/readline'
