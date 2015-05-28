require 'spec_helper'

RSpec.describe Clin::OptionList do
  describe '#on' do
    let(:name) { Faker::Lorem.word }
    let(:description) { Faker::Lorem.sentence }
    let(:out) { Hash.new }
    context 'when normal list option' do
      subject { Clin::OptionList.new(name, description) }
      before do
        subject.on('val1', out)
        subject.on('val2', out)
      end

      it { expect(out[name]).to be_a Array }
      it { expect(out[name].size).to be 2 }
      it { expect(out[name]).to include('val1') }
      it { expect(out[name]).to include('val2') }
    end

    context 'when flag list option' do
      subject { Clin::OptionList.new(name, description, argument: false) }
      before do
        subject.on(true, out)
        subject.on(true, out)
      end

      it { expect(out[name]).to be_a Integer }
      it { expect(out[name]).to be 2 }
    end
  end
end
