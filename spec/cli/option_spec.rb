require 'spec_helper'
require 'clin/option'

RSpec.describe Clin::Option do
  describe '#initialize' do
    context 'when initializing with name' do
      subject { Clin::Option.new(:my_option, '-m', '--myoption', 'This is my option!') }
      it { expect(subject.name).to eq(:my_option) }
      it { expect(subject.args).to eq(['-m', '--myoption', 'This is my option!']) }
      it { expect(subject.block).to be nil }
    end

    context 'when initializing with block' do
      let(:block) { proc { puts 'Do stuff' } }
      subject { Clin::Option.new('-m', '--myoption', 'This is my option!', &block) }
      it { expect(subject.name).to be nil }
      it { expect(subject.args).to eq(['-m', '--myoption', 'This is my option!']) }
      it { expect(subject.block).to eq(block) }
    end
  end

  describe '#extract' do
    let(:out) { Hash.new }
    let(:opts) { double(:opts) }
    let(:value) { 'some' }
    before do
      allow(opts).to receive(:on) do |*_args, &block|
        block.call(value)
      end
    end

    context 'when initializing with name' do
      subject { Clin::Option.new(:my_option, '-m', '--myoption', 'This is my option!') }
      before do
        subject.extract(opts, out)
      end
      it { expect(opts).to have_received(:on).once }
      it { expect(out[:my_option]).to eq(value) }
    end

    context 'when initializing with block' do
      let(:block) { proc { |_opts, out, value| out[:some] = value } }
      subject { Clin::Option.new('-m', '--myoption', 'This is my option!', &block) }
      before do
        subject.extract(opts, out)
      end
      it { expect(opts).to have_received(:on).once }
      it { expect(out[:some]).to eq(value) }

    end
  end

  describe '#on' do
    let(:out) { Hash.new }
    let(:value) { 'Some value' }
    subject { Clin::Option.new(:my_option, '-m', '--myoption', 'This is my option!') }

    before do
      subject.on(value, out)
    end
    it { expect(out[:my_option]).to eq(value) }
  end
end
