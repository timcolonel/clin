require 'clin'

# Handle the file_conflict interaction with the user.
class Clin::ShellInteraction::FileConflict < Clin::ShellInteraction
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
    when :yes
      return true
    when :no
      return false
    when :always
      return persist!
    when :quit
      puts 'Aborting...'
      fail SystemExit
    when :diff
      show_diff(filename, block.call)
      return nil
    else
      return nil
    end
  end

  protected def file_conflict_choices
    {yes: 'Overwrite',
     no: 'Do not Overwrite',
     always: 'Override this and all the next',
     quit: 'Abort!',
     diff: 'Show the difference',
     help: 'Show this'}
  end

  protected def show_diff(old_file, new_content)
    Tempfile.open(File.basename(old_file)) do |f|
      f.write new_content
      f.rewind
      system %(#{Clin.diff_cmd} "#{old_file}" "#{f.path}")
    end
  end
end
