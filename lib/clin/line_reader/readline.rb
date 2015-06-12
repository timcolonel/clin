require 'readline'

# Readline line scanner.
# Allow autocomplete and history.
# Use Readline.readline
# Valid options:
# echo: [Boolean] Set to false not to show on screen what you type(e.g. password)
# autocomplete: List of values to autocomplete or proc that return the values
# add_to_history: [Boolean] Add the reply to the history, default: true
class Clin::LineReader::Readline < Clin::LineReader::Basic
  def self.available?
    Clin.use_readline?
  end

  def readline
    if echo?
      Readline.completion_append_character = nil
      set_completion_proc
      Readline.readline(statement, add_to_history?)
    else # Use basic method to fetch
      super
    end
  end

  # Set the auto-completion process if applicable
  protected def set_completion_proc
    proc = completion_proc
    Readline.completion_proc = proc unless proc.nil?
  end

  # Return nil if no completion given as option
  # @return [Proc] Auto-completion process
  protected def completion_proc
    return nil unless autocomplete?
    if autocomplete.is_a? Proc
      autocomplete
    else
      proc { |s| autocomplete.grep(/^#{Regexp.escape(s)}/) }
    end
  end

  protected def autocomplete
    options[:autocomplete]
  end

  protected def autocomplete?
    options.fetch(:autocomplete, false)
  end

  protected def add_to_history?
    options.fetch(:add_to_history, true)
  end
end
