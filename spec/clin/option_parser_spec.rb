require 'clin'

RSpec.describe Clin::OptionParser do
  describe '#handle_unknown_option' do
    let(:name) { :verbose }
    let(:value) { Faker::Lorem.word }

    context 'when command does not allow unknown options' do
      let(:command) { double(:command, skip_options?: false) }
      subject { Clin::OptionParser.new(command, []) }

      before do
        subject.handle_unknown_option(name, nil)
      end

      it { expect(subject.errors.size).to be 1 }
      it { expect(subject.errors.first).to be_a Clin::UnknownOptionError }
      it { expect(subject.skipped_options).to be_empty }
    end

    context 'when command allow unknown options and value is given' do
      let(:command) { double(:command, skip_options?: true) }
      subject { Clin::OptionParser.new(command, []) }

      before do
        subject.handle_unknown_option(name, value)
      end

      it { expect(subject.skipped_options.size).to eq 2 }
      it { expect(subject.skipped_options).to eq [name, value] }
    end

    context 'when command allow unknown options and value is nil' do
      let(:command) { double(:command, skip_options?: true) }
      subject { Clin::OptionParser.new(command, []) }

      before do
        allow(subject).to receive(:complete).and_return(value)
        subject.handle_unknown_option(name, nil)
      end

      it { expect(subject.skipped_options.size).to eq 2 }
      it { expect(subject.skipped_options).to eq [name, value] }
    end
  end

  describe '#complete' do
    let(:command) { double(:command) }
    let(:value) { Faker::Lorem.word }
    it 'keep the value when the value exists' do
      parser = Clin::OptionParser.new(command, ['some'])
      expect(parser.complete(value)).to eq(value)
      expect(parser.instance_variable_get(:@argv)).to eq(['some'])
    end

    it 'get next argument value when the value is nil' do
      parser = Clin::OptionParser.new(command, [value])
      expect(parser.complete(nil)).to eq(value)
      expect(parser.instance_variable_get(:@argv)).to eq([])
    end

    it 'return nil when value is nil and next argument is an option' do
      parser = Clin::OptionParser.new(command, ['-o'])
      expect(parser.complete(nil)).to be nil
      expect(parser.instance_variable_get(:@argv)).to eq(['-o'])
    end
  end

  describe '#parse_next' do
    let(:command) { double(:command) }
    context 'when option is a long option' do
      subject { Clin::OptionParser.new(command, ['--opt=val']) }
      before do
        allow(subject).to receive(:parse_long)
        subject.parse_next
      end
      it { expect(subject).to have_received(:parse_long).with('--opt', 'val') }
      it { expect(subject.instance_variable_get(:@argv)).to be_empty }
      it { expect(subject.instance_variable_get(:@arguments)).to be_empty }
    end

    context 'when option is a short option' do
      subject { Clin::OptionParser.new(command, ['-oval']) }
      before do
        allow(subject).to receive(:parse_short)
        subject.parse_next
      end
      it { expect(subject).to have_received(:parse_short).with('-o', 'val') }
      it { expect(subject.instance_variable_get(:@argv)).to be_empty }
      it { expect(subject.instance_variable_get(:@arguments)).to be_empty }
    end

    context 'when option is not an option' do
      subject { Clin::OptionParser.new(command, ['not opt']) }
      before do
        subject.parse_next
      end
      it { expect(subject.instance_variable_get(:@argv)).to be_empty }
      it { expect(subject.instance_variable_get(:@arguments)).to eq(['not opt']) }
    end
  end
end
