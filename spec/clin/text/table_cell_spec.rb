require 'spec_helper'

RSpec.describe Clin::Text::TableCell do
  def table_double(options)
    double(:table, options.reverse_merge(column_length: {}, update_column_length: true))
  end

  describe '#length' do
    let(:index) { 1 }
    let(:table) { table_double(column_length: [1, 2, 3]) }
    subject { Clin::Text::TableCell.new(table, index, 'val') }

    it 'Get the length of the corresponding column' do
      expect(subject.length).to eq(2)
    end
  end

  describe '#align' do
    let(:index) { 1 }
    let(:table) { table_double(align: align) }
    subject { Clin::Text::TableCell.new(table, 1, 'val') }

    context 'when align was set using a symbol' do
      let(:align) { :center }

      it 'return the global align setting' do
        expect(subject.align).to eq(align)
      end
    end

    context 'when align was set column specific' do
      let(:align) { [:center, :right, :center] }

      it 'return the column specific setting' do
        expect(subject.align).to eq(:right)
      end
    end

    context 'when align is in wrong format' do
      let(:align) { {left: true} }

      it 'return the column specific setting' do
        expect { subject.align }.to raise_error(Clin::Error)
      end
    end
  end

  describe '#to_s' do
    let(:table) { table_double(column_length: {}) }
    subject { Clin::Text::TableCell.new(table, 1, 'value') }

    before do
      allow(subject).to receive(:length).and_return(9)
      allow(subject).to receive(:align).and_return(align)
    end

    context 'when align is left' do
      let(:align) { :left }
      it { expect(subject.to_s).to eq('value    ') }
    end

    context 'when align is right' do
      let(:align) { :right }
      it { expect(subject.to_s).to eq('    value') }
    end

    context 'when align is center' do
      let(:align) { :center }
      it { expect(subject.to_s).to eq('  value  ') }
    end
  end
end
