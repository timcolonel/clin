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
    before do
      allow(subject).to receive(:parse_short)
      allow(subject).to receive(:parse_long)
      subject.parse_next
    end
    context 'when option is a long option' do
      subject { Clin::OptionParser.new(command, ['--opt=val']) }
      it { expect(subject).to have_received(:parse_long).with('--opt', 'val') }
      it { expect(subject).not_to have_received(:parse_short) }
      it { expect(subject.instance_variable_get(:@argv)).to be_empty }
      it { expect(subject.instance_variable_get(:@arguments)).to be_empty }
    end

    context 'when option is a short option' do
      subject { Clin::OptionParser.new(command, ['-oval']) }
      it { expect(subject).not_to have_received(:parse_long) }
      it { expect(subject).to have_received(:parse_short).with('-o', 'val') }
      it { expect(subject.instance_variable_get(:@argv)).to be_empty }
      it { expect(subject.instance_variable_get(:@arguments)).to be_empty }
    end

    context 'when option is not an option' do
      subject { Clin::OptionParser.new(command, ['not opt']) }
      it { expect(subject).not_to have_received(:parse_short) }
      it { expect(subject).not_to have_received(:parse_long) }
      it { expect(subject.instance_variable_get(:@argv)).to be_empty }
      it { expect(subject.instance_variable_get(:@arguments)).to eq(['not opt']) }
    end
  end

  describe '#parse' do
    let(:command) { double(:command) }
    subject { Clin::OptionParser.new(command, []) }

    it 'call parse_next until it return false' do
      expect(subject).to receive(:parse_next).and_return(true, true, false).exactly(3).times
      subject.parse
    end
  end

  describe '#parse_option' do
    let(:command) { double(:command) }
    subject { Clin::OptionParser.new(command, []) }


    before do
      allow(subject).to receive(:handle_unknown_option)
      allow(subject).to receive(:parse_flag_option)
      subject.parse_option(option, '-o', value, true)
    end

    context 'when option is nil' do
      let(:value) { 'val' }
      let(:option) { nil }
      it { expect(subject).to have_received(:handle_unknown_option) }
      it { expect(subject).not_to have_received(:parse_flag_option) }
    end

    context 'when option is a flag' do
      let(:value) { 'val' }
      let(:option) { double(:option, flag?: true) }
      it { expect(subject).not_to have_received(:handle_unknown_option) }
      it { expect(subject).to have_received(:parse_flag_option) }
    end

    context 'when value is nil and argument is required' do
      let(:value) { nil }
      let(:option) { double(:option, flag?: false, argument_optional?: false) }

      it { expect(subject).not_to have_received(:handle_unknown_option) }
      it { expect(subject).not_to have_received(:parse_flag_option) }
      it { expect(subject.errors.first).to be_a(Clin::MissingOptionArgumentError) }
    end

    context 'when argument is optional or value is defined' do
      let(:value) { nil }
      let(:option) { double(:option, flag?: false, argument_optional?: true, trigger: true) }

      it { expect(subject).not_to have_received(:handle_unknown_option) }
      it { expect(subject).not_to have_received(:parse_flag_option) }
      it { expect(subject.errors).to be_empty }
      it { expect(option).to have_received(:trigger).with(subject, subject.options, true) }
    end
  end

  describe '#parse_flag_option' do
    let(:command) { double(:command) }
    subject { Clin::OptionParser.new(command, []) }
    let(:option) { double(:option, flag?: true, trigger: true) }

    before do
      allow(subject).to receive(:parse_compact_flag_options)
      subject.parse_flag_option(option, value, short?)
    end

    context 'when value is nil' do
      let(:value) { nil }
      let(:short?) { false }
      it { expect(option).to have_received(:trigger).with(subject, subject.options, true) }
    end

    context 'when value exist and name is long' do
      let(:value) { 'val' }
      let(:short?) { false }
      it { expect(option).not_to have_received(:trigger) }
      it { expect(subject.errors.first).to be_a(Clin::OptionUnexpectedArgumentError) }
    end

    context 'when value exist and name is short' do
      let(:value) { 'abc' }
      let(:short?) { true }
      it { expect(option).to have_received(:trigger).with(subject, subject.options, true) }
      it { expect(subject).to have_received(:parse_compact_flag_options) }
    end
  end

  describe '#parse_compact_flag_options' do
    let(:command) { double(:command) }
    subject { Clin::OptionParser.new(command, []) }

    let (:option1) { double(:option, flag?: true) }
    let (:option2) { double(:option, flag?: true) }
    let (:invalid_option) { double(:option, flag?: false) }

    before do
      allow(subject).to receive(:parse_flag_option)
      allow(command).to receive(:find_option_by).and_return(*options)
      subject.parse_compact_flag_options(options_arg)
    end

    context 'when options are only valid flag options' do
      let(:options_arg) { 'ab' }
      let(:options) { [option1, option2] }

      it { expect(subject).to have_received(:parse_flag_option).twice }
      it { expect(subject.errors).to be_empty }
    end

    context 'when 1 option is not a flag' do
      let(:options_arg) { 'abc' }
      let(:options) { [option1, invalid_option, option2] }

      it { expect(subject).to have_received(:parse_flag_option).once }
      it { expect(subject.errors.first).to be_a Clin::OptionError }
    end
  end
end
