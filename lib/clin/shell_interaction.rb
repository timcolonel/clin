require 'clin'

# Parent class for shell interaction.
class Clin::ShellInteraction
  class << self
    attr_accessor :persist
  end

  attr_accessor :shell

  # @param shell [Clin::Shell] Shell starting the interaction.
  def initialize(shell)
    @shell = shell
    self.class.persist ||= {}
  end

  # @return [Boolean]
  def persist?
    self.class.persist[@shell] ||= false
  end

  # Mark the current shell to persist file interaction
  def persist!
    self.class.persist[@shell] = persist_answer
  end

  def persist_answer
    true
  end
end

require 'clin/shell_interaction/file_conflict'
require 'clin/shell_interaction/yes_or_no'
require 'clin/shell_interaction/choose'
require 'clin/shell_interaction/select'
