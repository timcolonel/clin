require 'clin'
require 'clin/text'

# Handle a choose question. Where you select the choices with a number
# $ Choose:
# 1. Choice A
# 2. Choice B
# 3. Choice B
#
class Clin::ShellInteraction::Select < Clin::ShellInteraction::Choose
  def run(statement, choices, default: nil, start_index: 1)
    choices = convert_choices(choices)
    loop do
      puts statement
      puts choice_help(choices, start_index)
      answer = @shell.ask('>', default: default, autocomplete: choices.keys)
      next if answer.nil?
      choice = get_choice(choices, answer, start_index)
      return choice unless choice.nil?
    end
  end

  def choice_help(choices, start_index)
    Clin::Text::Table.new(border: false, col_delim: ' ') do |t|
      i = start_index
      choices.each do |key, description|
        key = "#{key}," unless description.blank?
        row = ["#{i}.", key]
        row << description unless description.blank?
        t.row row
        i += 1
      end
    end
  end

  def get_choice(choices, answer, start_index)
    i = start_index
    choices.each do |choice, _|
      return choice if choice.casecmp(answer) == 0 || i.to_s == answer
      i += 1
    end
    nil
  end
end
