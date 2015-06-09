require 'clin'

RSpec.describe Clin::OptionParser do
  describe 'handle_unknown_option' do
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
end
