require 'clin'

# Class the offer helper method to interact with the user using the command line
class Clin::Shell
  # Input stream, default: STDIN
  attr_accessor :in

  # Output stream, default: STDOUT
  attr_accessor :out

  def initialize(input: STDIN, output: STDOUT)
    @in = input
    @out = output
    @yes_or_no_persist = false
  end

  # Ask a question
  def ask(statement, default: nil)
    answer = scan(statement)
    if answer.blank?
      default
    else
      answer.strip
    end
  end

  # Ask a question and expect the result to be in the list of choices
  # Will continue asking until the input is correct
  # or if a default value is supplied then empty will return.
  # @param statement [String] Question to ask
  # @param choices [Array] List of choices
  # @param default [String] Default value if the user put blank value.
  # @param allow_initials [Boolean] Allow the user to reply with only the inital of the choice.
  #   (e.g. yes/no => y/n)
  # If multiple choices start with the same initial
  # ONLY the first one will be able to be selected using its inital
  def choose(statement, choices, default: nil, allow_initials: false)
    question = prepare_question(statement, choices, default: default, initials: allow_initials)
    choices = convert_choices(choices)
    loop do
      answer = ask(question, default: default)
      unless answer.nil?
        choices.each do |choice, _|
          if choice.casecmp(answer) == 0 || (allow_initials && choice[0].casecmp(answer[0]) == 0)
            return choice
          end
        end
      end
      print_choices_help(choices, allow_initials: allow_initials)
    end
  end

  # Expect the user the return yes or no(y/n also works)
  # @param statement [String] Question to ask
  # @param default [String] Default value(yes/no)
  # @param persist [Boolean] Add "all" to the choices. When all is selected all the following call
  #   to yes_or_no with persist: true will return true instead of asking the user.
  def yes_or_no(statement, default: nil, persist: false)
    options = %w(yes no)
    if persist
      return true if @yes_or_no_persist
      options << 'all'
    end
    choice = choose(statement, options, default: default, allow_initials: true)
    if choice == 'all'
      choice = 'yes'
      @yes_or_no_persist = true
    end
    choice == 'yes'
  end

  # Yes or no question defaulted to yes
  # @param options [Hash] Named parameters for yes_or_no
  # @see #yes_or_no
  def yes?(statement, options = {})
    options[:default] = 'yes'
    yes_or_no(statement, **options)
  end

  # Yes or no question defaulted to no
  # @param options [Hash] Named parameters for yes_or_no
  # @see #yes_or_no
  def no?(statement, options = {})
    options[:default] = 'no'
    yes_or_no(statement, **options)
  end

  protected def scan(statement)
    @out.print(statement + ' ')
    @in.gets
  end

  protected def choice_message(choices, default: nil, initials: false)
    choices = choices.map { |x| x == default ? x.upcase : x }
    msg = if initials
            choices.map { |x, _| x[0] }.join('')
          else
            choices.join(',')
          end
    "[#{msg}]"
  end

  protected def prepare_question(statement, choices, default: nil, initials: false)
    question = statement.clone
    question << " #{choice_message(choices, default: default, initials: initials)}"
  end

  protected def print_choices_help(choices, allow_initials: false)
    puts 'Choose from:'
    used_initials = Set.new
    choices.each do |choice, description|
      suf = choice.to_s
      suf += ", #{description}" unless description.blank?
      line = if allow_initials && !used_initials.include?(choice[0])
               used_initials << choice[0]
               "  #{choice[0]} - #{suf}"
             else
               "      #{suf}"
             end
      puts line
    end
  end

  # Convert the choices to a hash with key being the choice and value the description
  protected def convert_choices(choices)
    if choices.is_a? Array
      Hash[*choices.map { |k| [k.to_s, ''] }.flatten]
    elsif choices.is_a? Hash
      Hash[choices.map { |k, v| [k.to_s, v] }]
    end
  end
end
