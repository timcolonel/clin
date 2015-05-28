require 'spec_helper'
require 'clin/command_options_mixin'

RSpec.describe Clin::CommandOptionsMixin do
  describe '#add_option' do
    subject { Class.new(Clin::CommandOptionsMixin) }
    let(:option) { Clin::Option.new(:name, '-n') }
    before do
      subject.add_option option
    end

    it { expect(subject.options.size).to be 1 }
    it { expect(subject.options.first).to eq option }
    it { expect(Clin::CommandOptionsMixin.options.size).to be 0 }
  end

  describe '#option' do
    subject { Class.new(Clin::CommandOptionsMixin) }
    let(:args) { [:name, '-n'] }
    let(:option) { Clin::Option.new(*args) }

    before do
      allow(subject).to receive(:add_option)
      subject.option(*args)
    end

    it { expect(subject).to have_received(:add_option).with(option) }

  end

  describe '#general_option' do
    subject { Class.new(Clin::CommandOptionsMixin) }
    let(:option) { double(:option, register_options: true, new: true) }
    before do
      subject.general_option option
    end
    it { expect(option).to have_received(:new) }
    it { expect(subject.general_options.size).to be 1 }
    it { expect(subject.general_options.values.first).to eq(true) }
    it { expect(Clin::CommandOptionsMixin.general_options.size).to be 0 }
  end

  describe '#register_options' do
    subject { Class.new(Clin::CommandOptionsMixin) }
    let(:opt1) { double(:option, register: true) }
    let(:opt2) { double(:option, register: true) }
    let(:g_opt_cls) { double(:general_option_class, register_options: true) }
    let(:g_opt) { double(:general_option, class: g_opt_cls) }
    let(:opts) { double(:options) }
    let(:out) { double(:out) }
    before do
      subject.add_option(opt1)
      subject.add_option(opt2)
      subject.general_options = {g_opt_cls => g_opt}

      subject.register_options(opts, out)
    end

    it { expect(opt1).to have_received(:register).with(opts, out) }
    it { expect(opt2).to have_received(:register).with(opts, out) }
    it { expect(g_opt_cls).to have_received(:register_options).with(opts, out) }

  end
end
