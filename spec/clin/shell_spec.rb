require 'clin'

RSpec.describe Clin::Shell do
  def expects_scan(message, *outputs)
    expect(subject).to receive(:scan).with(message, any_args).and_return(*outputs).exactly(outputs.size).times
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

  describe '#password' do
    it 'call ask with echo and add_to_history false' do
      expect(subject).to receive(:ask)
                           .with('Password?', default: 'lorem', echo: false, add_to_history: false)
      subject.password('Password?', default: 'lorem')
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
  end

  describe '#select' do
    it 'call ask with echo and add_to_history false' do
      select = double(:select_interaction)
      choices = %w(France Germany Italy Spain)
      expect(select).to receive(:run).with('Where are you from?', choices, default: 'France')
      expect(Clin::ShellInteraction::Select).to receive(:new).and_return(select)
      subject.select('Where are you from?', choices, default: 'France')
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
      expects_scan('Is earth round? [yna]', 'a')
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
      expects_scan("Overwrite 'some1.txt'? [Ynaqh]", 'a')
      expect(subject.overwrite?('some1.txt')).to be true
      expect(subject.overwrite?('some2.txt')).to be true
      expect(subject.overwrite?('some3.txt')).to be true
    end

    it 'ask the user and quit when he reply quit' do
      expects_scan("Overwrite 'some.txt'? [Ynaqh]", 'q')
      expect { subject.overwrite?('some.txt') }.to raise_error(SystemExit)
    end

    it 'ask the user and show diff when he reply diff' do
      expects_scan("Overwrite 'some.txt'? [Ynaqdh]", 'd', 'y')
      expect_any_instance_of(Clin::ShellInteraction::FileConflict)
        .to receive(:show_diff).with('some.txt', 'new_text')
      result = subject.overwrite?('some.txt') do
        'new_text'
      end
      expect(result).to be true
    end
  end

  describe '#keep?' do
    it 'ask the user and return true when he reply yes' do
      expects_scan("Overwrite 'some.txt'? [yNaqh]", '')
      expect(subject.keep?('some.txt')).to be false
    end
  end

  describe '#scan' do
    it 'call LineReader.scan' do
      options = {opt1: 'val1', opt2: 'val2'}
      expect(Clin::LineReader).to receive(:scan).with(subject, 'Where are you from? ', options)
      subject.send(:scan, 'Where are you from?', options)
    end
  end
end
