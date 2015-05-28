require 'spec_helper'
require 'clin/argument'

RSpec.describe Clin::Argument do

  describe '#check_optional' do
    subject { Clin::Argument.new('') }
    it { expect(subject.check_optional('not_optional')).to eq('not_optional') }
    it { expect(subject.check_optional('<not_optional>')).to eq('<not_optional>') }
    it { expect(subject.check_optional('[optional]')).to eq('optional') }
    it { expect(subject.check_optional('[<optional>]')).to eq('<optional>') }
    it { expect(subject.check_optional('[<optional>...]')).to eq('<optional>...') }
    it { expect(subject.check_optional('[optional...]')).to eq('optional...') }
    it { expect { subject.check_optional('[optional') }.to raise_error(Clin::Error) }
    it { expect { subject.check_optional('[optional]...') }.to raise_error(Clin::Error) }

    it 'expect optional to set instance variable' do
      subject.check_optional('[optional]')
      expect(subject.optional).to be true
    end

    it 'expect not optional to keep instance variable' do
      subject.check_optional('not_optional')
      expect(subject.optional).to be false
    end
  end

  describe '#check_multiple' do
    subject { Clin::Argument.new('') }
    it { expect(subject.check_multiple('multiple...')).to eq('multiple') }
    it { expect(subject.check_multiple('<multiple>...')).to eq('<multiple>') }
    it { expect(subject.check_multiple('not_multiple')).to eq('not_multiple') }
    it { expect(subject.check_multiple('<not_multiple>')).to eq('<not_multiple>') }

    it 'expect to set instance variable' do
      subject.check_multiple('multiple...')
      expect(subject.multiple).to be true
    end

    it 'expect not to set instance variable' do
      subject.check_multiple('not_multiple')
      expect(subject.multiple).to be false
    end
  end

  describe '#check_variable' do
    subject { Clin::Argument.new('') }
    it { expect(subject.check_variable('not_variable')).to eq('not_variable') }
    it { expect(subject.check_variable('<variable>')).to eq('variable') }

    it { expect { subject.check_variable('<variable') }.to raise_error(Clin::Error) }
    it { expect { subject.check_variable('<variable...') }.to raise_error(Clin::Error) }
    it 'expect optional to set instance variable' do
      subject.check_variable('<variable>')
      expect(subject.variable).to be true
    end

    it 'expect not optional to keep instance variable' do
      subject.check_variable('not_variable')
      expect(subject.variable).to be false
    end
  end

  describe '#initialize' do
    subject { Clin::Argument.new('[<optional_var_mul>...]') }
    it { expect(subject.name).to eq('optional_var_mul') }
    it { expect(subject.optional).to be true }
    it { expect(subject.multiple).to be true }
    it { expect(subject.variable).to be true }
  end

  describe 'parse' do
    context 'when argument is optional' do
      subject { Clin::Argument.new('[<optional>]') }

      it 'get the argument' do
        value, rem = subject.parse(%w(value1 value2))
        expect(value).to eq('value1')
        expect(rem).to eq(['value2'])
      end

      it 'work when there is no argument' do
        value, rem = subject.parse([])
        expect(value).to be nil
        expect(rem).to eq([])
      end
    end

    context 'when multiple arguments are allowed' do
      subject { Clin::Argument.new('<multiple>...') }

      it 'get the argument' do
        value, rem = subject.parse(%w(value1 value2))
        expect(value).to eq(%w(value1 value2))
        expect(rem).to eq([])
      end

      it { expect { subject.parse([]).to raise_error(Clin::CommandLineError) } }
    end

    context 'when argument must match exactly' do
      subject { Clin::Argument.new('argument') }

      it 'get the argument' do
        value, rem = subject.parse(['argument'])
        expect(value).to eq('argument')
        expect(rem).to eq([])
      end
      it { expect { subject.parse(['other_value']).to raise_error(Clin::CommandLineError) } }
    end

    context 'when multiple argument must match exactly' do
      subject { Clin::Argument.new('argument...') }
      it { expect { subject.parse(%w(argument other_value)).to raise_error(Clin::CommandLineError) } }
    end
  end
end
