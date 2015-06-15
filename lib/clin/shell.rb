require 'clin'
require 'clin/line_reader'

# Class the offer helper method to interact with the user using the command line
class Clin::Shell
  # Input stream, default: STDIN
  attr_accessor :in

  # Output stream, default: STDOUT
  attr_accessor :out

  # Text builder instance that is used to stream
  attr_accessor :text

  def initialize(input: STDIN, output: STDOUT)
    @in = input
    @out = output
    @yes_or_no_persist = false
    @override_persist = false
    @text = Clin::Text.new
  end

  def say(line, indent: '')
    @out.puts text.line(line, indent: indent)
  end

  # Indent the current output
  def indent(indent, &block)
    text.indent(indent, &block)
  end

  # Ask a question
  # @param statement [String]
  # @param default [String]
  # @param autocomplete [Array|Proc] Filter for autocomplete (Need Readline)
  # @param echo [Boolean] If false no character will be displayed during input
  # @param add_to_history [Boolean] If the answer should be added to history. (Need Readline)
  def ask(statement, default: nil, autocomplete: nil, echo: true, add_to_history: true)
    answer = scan(statement, autocomplete: autocomplete, echo: echo, add_to_history: add_to_history)
    if answer.blank?
      default
    else
      answer.strip
    end
  end

  def password(statement, default: nil)
    ask(statement, default: default, echo: false, add_to_history: false)
  end

  # Ask a question and expect the result to be in the list of choices
  # Will continue asking until the input is correct
  # or if a default value is supplied then empty will return.
  # @param statement [String] Question to ask
  # @param choices [Array] List of choices
  # @param default [String] Default value if the user put blank value.
  # @param allow_initials [Boolean] Allow the user to reply with only the initial of the choice.
  #   (e.g. yes/no => y/n)
  # If multiple choices start with the same initial
  # ONLY the first one will be able to be selected using its initial
  def choose(statement, choices, default: nil, allow_initials: false)
    Clin::ShellInteraction::Choose.new(self).run(statement, choices,
                                                 default: default, allow_initials: allow_initials)
  end

  # Ask a question with a list of possible answer.
  # Answer can either be selected using their name or their index
  # e.g.
  # Select answer:
  # 1. Choice A
  # 2. Choice B
  # 3. Choice C
  def select(statement, choices, default: nil)
    Clin::ShellInteraction::Select.new(self).run(statement, choices, default: default)
  end

  # Expect the user the return yes or no(y/n also works)
  # @param statement [String] Question to ask
  # @param default [String] Default value(yes/no)
  # @param persist [Boolean] Add "always" to the choices. When all is selected all the following
  # call to yes_or_no with persist: true will return true instead of asking the user.
  def yes_or_no(statement, default: nil, persist: false)
    Clin::ShellInteraction::YesOrNo.new(self).run(statement, default: default, persist: persist)
  end

  # Yes or no question defaulted to yes
  # @param options [Hash] Named parameters for yes_or_no
  # @see #yes_or_no
  def yes?(statement, options = {})
    options[:default] = :yes
    yes_or_no(statement, **options)
  end

  # Yes or no question defaulted to no
  # @param options [Hash] Named parameters for yes_or_no
  # @see #yes_or_no
  def no?(statement, options = {})
    options[:default] = :no
    yes_or_no(statement, **options)
  end

  # File conflict helper method.
  # Give the following options to the user
  # - yes, Yes for this one
  # - no, No for this one
  # - all, Yes for all one
  # - quit, Quit the program
  # - diff, Diff the 2 files
  # @param filename [String] Filename with the conflict
  # @param block [Block] optional block that give the new content in case of diff
  # @return [Boolean] If the file should be overwritten.
  def file_conflict(filename, default: nil, &block)
    Clin::ShellInteraction::FileConflict.new(self).run(filename, default: default, &block)
  end

  # File conflict question defaulted to yes
  def overwrite?(filename, &block)
    file_conflict(filename, default: :yes, &block)
  end

  # File conflict question defaulted to no
  def keep?(filename, &block)
    file_conflict(filename, default: :no, &block)
  end

  # Prompt the statement to the user and return his reply.
  protected def scan(statement, options = {})
    Clin::LineReader.scan(self, statement + ' ', options)
  end
end

require 'clin/shell_interaction'
