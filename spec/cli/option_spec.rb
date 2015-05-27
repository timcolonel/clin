require 'spec_helper'
require 'clin/option'

RSpec.describe Clin::Option do
  describe '#initialize' do
    context 'when initializing with name' do
      subject { Clin::Option.new(:custom, 'This is my option!') }
      it { expect(subject.name).to eq(:custom) }
      it { expect(subject.short).to eq('-c') }
      it { expect(subject.long).to eq('--custom') }
      it { expect(subject.argument.to_s).to eq('CUSTOM') }
      it { expect(subject.block).to be nil }
    end

    context 'when initializing with block' do
      let(:block) { proc { puts 'Do stuff' } }
      subject { Clin::Option.new(:my_option, 'This is my option!', &block) }
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
      subject { Clin::Option.new(:my_option, 'This is my option!') }
      before do
        subject.register(opts, out)
      end
      it { expect(opts).to have_received(:on).once }
      it { expect(out[:my_option]).to eq(value) }
    end

    context 'when initializing with block' do
      let(:block) { proc { |_opts, out, value| out[:some] = value } }
      subject { Clin::Option.new(:my_option, 'This is my option!', &block) }
      before do
        subject.register(opts, out)
      end
      it { expect(opts).to have_received(:on).once }
      it { expect(out[:some]).to eq(value) }

    end
  end

  describe '#on' do
    let(:out) { Hash.new }
    let(:value) { 'Some value' }
    subject { Clin::Option.new(:my_option, 'This is my option!') }

    before do
      subject.on(value, out)
    end
    it { expect(out[:my_option]).to eq(value) }
  end

  describe '#default_short' do
    subject { Clin::Option.new(:echo, Faker::Lorem.sentence) }

    it { expect(subject.default_short).to eq('-e') }
  end

  describe '#default_long' do
    subject { Clin::Option.new(:echo, Faker::Lorem.sentence) }

    it { expect(subject.default_long).to eq('--echo') }
  end

  describe '#default_argument' do
    subject { Clin::Option.new(:echo, Faker::Lorem.sentence) }

    it { expect(subject.default_argument.to_s).to eq('ECHO') }
  end

  describe '#short' do
    context 'when short is not specified' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence) }
      it { expect(subject.short).to eq('-e') }
    end

    context 'when is set' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence, short: '-c') }
      it { expect(subject.short).to eq('-c') }
    end

    context 'when short is set to false' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence, short: false) }
      it { expect(subject.short).to eq(nil) }
    end
  end

  describe '#long' do
    context 'when long is not specified' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence) }
      it { expect(subject.long).to eq('--echo') }
    end

    context 'when is set' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence, long: '--eko') }
      it { expect(subject.long).to eq('--eko') }
    end

    context 'when long is set to false' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence, long: false) }
      it { expect(subject.long).to eq(nil) }
    end
  end

  describe '#argument' do
    context 'when argument is not specified' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence) }
      it { expect(subject.argument).to eq('ECHO') }
    end

    context 'when is set' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence, argument: 'MESSAGE') }
      it { expect(subject.argument).to eq('MESSAGE') }
    end

    context 'when argument is set to false' do
      subject { Clin::Option.new(:echo, Faker::Lorem.sentence, argument: false) }
      it { expect(subject.argument).to eq(nil) }
    end
  end
end
