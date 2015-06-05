require 'clin'

RSpec.describe Clin::ShellInteraction::Choose do
  let(:shell) { Clin::Shell.new }
  subject { Clin::ShellInteraction::Choose.new(shell) }

  def expects_scan(message, *outputs)
    expect(shell).to receive(:scan).with(message).and_return(*outputs).exactly(outputs.size).times
  end

  describe '#choice_message' do
    let(:options) { {yes: '', no: '', maybe: ''} }
    it { expect(subject.send(:choice_message, options)).to eq('[yes,no,maybe]') }
    it { expect(subject.send(:choice_message, options, default: :yes)).to eq('[YES,no,maybe]') }
    it { expect(subject.send(:choice_message, options, default: :no)).to eq('[yes,NO,maybe]') }
    it { expect(subject.send(:choice_message, options, initials: true)).to eq('[ynm]') }
    it { expect(subject.send(:choice_message, options, default: :yes, initials: true)).to eq('[Ynm]') }
    it { expect(subject.send(:choice_message, options, default: :maybe, initials: true)).to eq('[ynM]') }
  end

  describe '#prepare_question' do
    let(:options) { {yes: '', no: '', maybe: ''} }
    it do
      expect(subject.send(:prepare_question, 'Is it true?', options))
        .to eq('Is it true? [yes,no,maybe]')
    end
  end

  describe '#run' do
    let(:countries) { %w(usa france germany italy) }

    it 'ask for a choice and return the user reply' do
      expects_scan('Where are you from? [usa,france,germany,italy]', 'France')
      expect(subject.run('Where are you from?', countries)).to eq('france')
    end

    it 'ask for a choice and return the default' do
      expects_scan('Where are you from? [usa,france,GERMANY,italy]', '')
      expect(subject.run('Where are you from?', countries, default: 'germany')).to eq('germany')
    end

    it 'ask for a choice and user can reply with initials' do
      expects_scan('Where are you from? [ufgi]', 'i')
      expect(subject.run('Where are you from?', countries, allow_initials: true)).to eq('italy')
    end

    it 'keep asking until the answer is valid' do
      expects_scan('Where are you from? [usa,france,germany,italy]', 'spain', 'russia', 'france')
      expect(subject).to receive(:print_choices_help).twice
      expect(subject.run('Where are you from?', countries)).to eq('france')
    end
  end
end
