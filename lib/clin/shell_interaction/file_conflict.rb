require 'clin'

# Handle the file_conflict interaction with the user.
class Clin::ShellInteraction::FileConflict < Clin::ShellInteraction
  # Run the file conflict interaction
  # @param filename [String] Filename in conflict
  # @param default [Symbol] Default choice(Must be a key defined in #file_conflict_choices)
  # @param &block [Proc] Return the new content.
  # Only if a block is given the option to see the difference will be provided
  def run(filename, default: nil, &block)
    choices = file_conflict_choices
    choices = choices.except(:diff) unless block_given?
    return true if persist?
    result = nil
    while result.nil?
      choice = @shell.choose("Overwrite '#{filename}'?", choices,
                             default: default, allow_initials: true)
      result = handle_choice(choice, filename, &block)
    end
    result
  end

  # Handle the use choice
  # @return [Boolean] true/false if the user made a choice or
  #   nil if the question needs to be asked again
  protected def handle_choice(choice, filename, &block)
    case choice
    when :yes # User said yes allow overwrite
      return true
    when :no # User said yes reject overwrite
      return false
    when :always # User said always allow overwrite and all the following
      return persist!
    when :quit # User ask to quit, exit the script.
      shell.say 'Aborting...'
      fail SystemExit
    when :diff # User ask to show the difference between the old and new content.
      show_diff(filename, block.call)
      return nil
    else
      return nil
    end
  end

  # Hash of possible actions
  # @return [Hash]
  protected def file_conflict_choices
    {yes: 'Overwrite',
     no: 'Do not Overwrite',
     always: 'Override this and all the next',
     quit: 'Abort!',
     diff: 'Show the difference',
     help: 'Show this'}
  end

  # Prompt the user the difference between the 2 files
  # @param old_file [String] filename to overwrite(having the old content)
  # @param new_content [String] new_content to put in the file
  protected def show_diff(old_file, new_content)
    Tempfile.open(File.basename(old_file)) do |f|
      f.write new_content
      f.rewind
      system %(#{Clin.diff_cmd} "#{old_file}" "#{f.path}")
    end
  end
end
