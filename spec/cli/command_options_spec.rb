require 'spec_helper'
require 'clin/command_options'

RSpec.describe Clin::CommandOptions do
  describe '#add_option' do
    subject { Class.new(Clin::CommandOptions) }
    let(:option) { Clin::Option.new(:name, '-n') }
    before do
      subject.add_option option
    end

    it { expect(subject.options.size).to be 1 }
    it { expect(subject.options.first).to eq option }
    it { expect(Clin::CommandOptions.options.size).to be 0 }
  end

  describe '#option' do
    subject { Class.new(Clin::CommandOptions) }
    let(:args) { [:name, '-n'] }
    let(:option) { Clin::Option.new(*args) }

    before do
      allow(subject).to receive(:add_option)
      subject.option(*args)
    end

    it { expect(subject).to have_received(:add_option).with(option) }

  end

  describe '#general_option' do
    subject { Class.new(Clin::CommandOptions) }
    let(:option) { Class.new(Clin::CommandOptions) }
    before do
      subject.general_option option
    end

    it { expect(subject.general_options.size).to be 1 }
    it { expect(subject.general_options.first).to eq option }
    it { expect(Clin::CommandOptions.general_options.size).to be 0 }
  end

  describe '#extract_options' do
    subject { Class.new(Clin::CommandOptions) }
    let(:opt1) { double(:option, extract: true) }
    let(:opt2) { double(:option, extract: true) }
    let(:g_opt) { double(:option, extract_options: true) }
    let(:opts) { double(:options) }
    let(:out) { double(:out) }
    before do
      subject.add_option(opt1)
      subject.add_option(opt2)

      subject.general_option(g_opt)

      subject.extract_options(opts, out)
    end

    it { expect(opt1).to have_received(:extract).with(opts, out) }
    it { expect(opt2).to have_received(:extract).with(opts, out) }
    it { expect(g_opt).to have_received(:extract_options).with(opts, out) }

  end
end
