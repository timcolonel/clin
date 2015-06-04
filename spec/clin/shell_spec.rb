require 'clin'

RSpec.describe Clin::Shell do
  def expects_scan(message, *outputs)
    expect(subject).to receive(:scan).with(message).and_return(*outputs)
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

  describe '#ask' do
    it 'ask for a question and return user reply' do
      expects_scan('What is your name?', 'Smith')
      expect(subject.ask('What is your name?')).to eq('Smith')
    end

    it 'ask for a question and return default' do
      expects_scan('What is your name?', '')
      expect(subject.ask('What is your name?', default: 'Brown')).to eq('Brown')
    end
  end

  describe '#choose' do
    let(:countries) { %w(usa france germany italy) }

    it 'ask for a choice and return the user reply' do
      expects_scan('Where are you from? [usa,france,germany,italy]', 'France')
      expect(subject.choose('Where are you from?', countries)).to eq('france')
    end

    it 'ask for a choice and return the default' do
      expects_scan('Where are you from? [usa,france,GERMANY,italy]', '')
      expect(subject.choose('Where are you from?', countries, default: 'germany')).to eq('germany')
    end

    it 'ask for a choice and user can reply with initials' do
      expects_scan('Where are you from? [ufgi]', 'i')
      expect(subject.choose('Where are you from?', countries, allow_initials: true)).to eq('italy')
    end

    it 'keep asking until the answer is valid' do
      expects_scan('Where are you from? [usa,france,germany,italy]', 'spain', 'russia', 'france')
      expect(subject).to receive(:print_choices_help).twice
      expect(subject.choose('Where are you from?', countries)).to eq('france')
    end
  end
  describe '#yes_or_no' do
    it 'asks the user and returns true if the user replies y' do
      expects_scan('Is earth round? [yn]', 'y')
      expect(subject.yes_or_no('Is earth round?')).to be true
    end

    it 'asks the user and returns true if the user replies yes' do
      expects_scan('Is earth round? [yn]', 'yes')
      expect(subject.yes_or_no('Is earth round?')).to be true
    end

    it 'asks the user and returns false if the user replies n' do
      expects_scan('Is earth flat? [yn]', 'n')
      expect(subject.yes_or_no('Is earth flat?')).to be false
    end

    it 'asks the user and returns false if the user replies no' do
      expects_scan('Is earth flat? [yn]', 'no')
      expect(subject.yes_or_no('Is earth flat?')).to be false
    end

    it 'asks the user and returns true if the user replies nothing' do
      expects_scan('Is earth round? [Yn]', '')
      expect(subject.yes_or_no('Is earth round?', default: 'yes')).to be true
    end

    it 'ask the user only once when he reply always' do
      expects_scan('Is earth round? [yna]', 'a').once
      expect(subject.yes_or_no('Is earth round?', persist: true)).to be true
      expect(subject.yes_or_no('Is earth round?', persist: true)).to be true
      expect(subject.yes_or_no('Is earth round?', persist: true)).to be true
    end
  end

  describe '#yes?' do
    it 'asks the user and returns true if the user replies yes' do
      expects_scan('Is earth round? [Yn]', 'y')
      expect(subject.yes?('Is earth round?')).to be true
    end

    it 'asks the user and returns false if the user replies no' do
      expects_scan('Is earth flat? [Yn]', 'n')
      expect(subject.yes?('Is earth flat?')).to be false
    end

    it 'ask the user and return true if the user replies nothing' do
      expects_scan('Is the earth not flat? [Yn]', '')
      expect(subject.yes?('Is the earth not flat?')).to be true
    end
  end

  describe '#no?' do
    it 'asks the user and returns true if the user replies yes' do
      expects_scan('Is earth round? [yN]', 'y')
      expect(subject.no?('Is earth round?')).to be true
    end

    it 'asks the user and returns false if the user replies no' do
      expects_scan('Is earth flat? [yN]', 'n')
      expect(subject.no?('Is earth flat?')).to be false
    end

    it 'ask the user and return false if the user replies nothing' do
      expects_scan('Is the earth flat? [yN]', '')
      expect(subject.no?('Is the earth flat?')).to be false
    end
  end

  describe '#overwrite?' do
    it 'ask the user and return true when he reply yes' do
      expects_scan("Overwrite 'some.txt'? [Ynaqh]", 'y')
      expect(subject.overwrite?('some.txt')).to be true
    end

    it 'ask the user and return false when he reply false' do
      expects_scan("Overwrite 'some.txt'? [Ynaqh]", 'n')
      expect(subject.overwrite?('some.txt')).to be false
    end

    it 'ask the user only once when he reply always' do
      expects_scan("Overwrite 'some1.txt'? [Ynaqh]", 'a').once
      expect(subject.overwrite?('some1.txt')).to be true
      expect(subject.overwrite?('some2.txt')).to be true
      expect(subject.overwrite?('some3.txt')).to be true
    end

    it 'ask the user and quit when he reply quit' do
      expects_scan("Overwrite 'some.txt'? [Ynaqh]", 'q')
      expect { subject.overwrite?('some.txt') }.to raise_error(SystemExit)
    end

    it 'ask the user and quit when he reply quit' do
      expects_scan("Overwrite 'some.txt'? [Ynaqdh]", 'd', 'y')
      expect(subject).to receive(:show_diff).with('some.txt', 'new_text').once
      result = subject.overwrite?('some.txt') do
        'new_text'
      end
      expect(result).to be true
    end
  end
end
