require 'clin'

# Handle a simple yes/no interaction
class Clin::ShellInteraction::YesOrNo < Clin::ShellInteraction
  def run(statement, default: nil, persist: false)
    default = default.to_sym unless default.nil?
    options = [:yes, :no]
    if persist
      return true if persist?
      options << :always
    end
    choice = @shell.choose(statement, options, default: default, allow_initials: true)
    return persist! if choice == :always
    choice == :yes
  end
end
