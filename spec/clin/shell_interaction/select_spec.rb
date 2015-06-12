require 'clin'

RSpec.describe Clin::ShellInteraction::Select do
  let(:shell) { Clin::Shell.new }
  subject { Clin::ShellInteraction::Select.new(shell) }

  def expects_scan(*outputs)
    expect(shell).to receive(:scan).with('>', any_args)
                       .and_return(*outputs).exactly(outputs.size).times
  end

  describe '#run' do
    suppress_puts
    let(:choices) { %w(usa france germany italy) }

    it 'ask for a choice and return the user reply' do
      expects_scan('france')
      expect(subject.run('Where are you from?', choices)).to eq('france')
    end

    it 'ask for a choice and return the default' do
      expects_scan('')
      expect(subject).to receive(:choice_help).once
      expect(subject.run('Where are you from?', choices, default: 'germany')).to eq('germany')
    end

    it 'get the value using index' do
      expects_scan('4')
      expect(subject).to receive(:choice_help).once
      expect(subject.run('Where are you from?', choices)).to eq('italy')
    end

    it 'keep asking until the answer is valid' do
      expects_scan('spain', 'russia', 'france')
      expect(subject).to receive(:choice_help).exactly(3).times
      expect(subject.run('Where are you from?', choices)).to eq('france')
    end

    it 'keep asking until the answer is valid' do
      expects_scan('0', '10', '2')
      expect(subject).to receive(:choice_help).exactly(3).times
      expect(subject.run('Where are you from?', choices)).to eq('france')
    end
  end

  describe '#get_choice' do
    let(:choices) { ['Choice A', 'Choice B', 'Choice C', 'Choice D'] }

    it 'get choice with its value' do
      expect(subject.get_choice(choices, 'Choice B', 1)).to eq('Choice B')
    end

    it 'get choice with its index' do
      expect(subject.get_choice(choices, '3', 1)).to eq('Choice C')
    end

    it 'return nil when value is less' do
      expect(subject.get_choice(choices, '0', 1)).to be nil
    end
    it 'return nil when value is less' do
      expect(subject.get_choice(choices, '5', 1)).to be nil
    end
  end

  describe '#choice_help' do
    def same?(value, actual)
      expect(value.to_s.split("\n").map(&:rstrip)).to eq(actual.to_s.split("\n").map(&:rstrip))
    end

    let(:choices) { ['Choice A', 'Choice B', 'Choice C'] }
    let(:choices_desc) { {'Choice A' => 'This is choice A',
                          'Choice Long' => 'This is choice B',
                          'Choice C' => 'This is choice C'} }
    it 'get help without description' do
      help = subject.choice_help(choices, 1).to_s
      expected = <<help
1. Choice A
2. Choice B
3. Choice C
help
      # same?(help, expected)
      expect(help).to eq(expected)
    end

    it 'get help with description' do
      help = subject.choice_help(choices_desc, 0).to_s
      expected = <<help
0. Choice A,    This is choice A
1. Choice Long, This is choice B
2. Choice C,    This is choice C
help
      # same?(help, expected)
      expect(help).to eq(expected)
    end
  end
end
