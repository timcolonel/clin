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
end
