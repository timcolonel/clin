require 'spec_helper'

RSpec.describe Clin::CommandMixin::Options do
  def new_subject
    a = Class.new
    a.include Clin::CommandMixin::Options
    a
  end

  describe '#add_option' do
    subject { new_subject }
    let(:option) { Clin::Option.new(:name, '-n') }
    before do
      subject.add_option option
    end

    it { expect(subject.options.size).to be 1 }
    it { expect(subject.options.first).to eq option }
  end

  describe '#option' do
    subject { new_subject }
    let(:args) { [:name, '-n'] }
    let(:option) { Clin::Option.new(*args) }

    before do
      allow(subject).to receive(:add_option)
      subject.option(*args)
    end

    it { expect(subject).to have_received(:add_option).with(option) }

  end

  describe '#general_option' do
    subject { new_subject }
    let(:option) { double(:option, register_options: true, new: true) }
    before do
      subject.general_option option
    end
    it { expect(option).to have_received(:new) }
    it { expect(subject.general_options.size).to be 1 }
    it { expect(subject.general_options.values.first).to eq(true) }
  end

  describe '#options' do
    subject { new_subject }
    let(:option1) { double(:option1) }
    let(:option2) { double(:option2) }
    let(:option3) { double(:option3) }
    let(:option4) { double(:option4) }
    let(:general_option1) do
      opt = Class.new(Clin::GeneralOption)
      opt.add_option option3
      opt.add_option option4
      opt
    end

    let(:general_option2) do
      opt = Class.new(Clin::GeneralOption)
      opt.general_option general_option1
      opt
    end

    it 'get every options' do
      subject.add_option option1
      subject.add_option option2
      expect(subject.options).to eq([option1, option2])
    end

    it 'get every general option options' do
      subject.general_option general_option1
      expect(subject.options).to eq([option3, option4])
    end

    it 'get every options and general option options' do
      subject.add_option option1
      subject.add_option option2
      subject.general_option general_option1
      expect(subject.options).to eq([option1, option2, option3, option4])
    end

    it 'get nested general options' do
      subject.add_option option1
      subject.add_option option2
      subject.general_option general_option2
      expect(subject.options).to eq([option1, option2, option3, option4])
    end
  end
end
