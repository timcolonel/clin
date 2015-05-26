require 'spec_helper'

RSpec.describe Clin::HelpOptions do
  describe 'options' do
    let(:out) { {} }
    it { expect(Clin::HelpOptions.options.size).to be 1 }
    it 'call the callback' do
      Clin::HelpOptions.options.first.block.call('opts', out, nil)
      expect(out).to eq({help: 'opts'})
    end
  end

  describe '#initialize' do
    it { expect(Clin::HelpOptions.new(raise: false).instance_variable_get(:@raise)).to be false }
    it { expect(Clin::HelpOptions.new.instance_variable_get(:@raise)).to be true }
  end

  describe '#execute' do
    let(:help) { Faker::Lorem.sentence }
    context 'when should raise' do
      subject { Clin::HelpOptions.new(raise: true) }
      it { expect { subject.execute({help: help}) }.to raise_error(Clin::HelpError) }
    end
    context 'when should not raise' do
      subject { Clin::HelpOptions.new(raise: false) }
      it { expect { subject.execute({help: help}) }.not_to raise_error }
    end
  end
end