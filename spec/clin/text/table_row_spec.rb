require 'spec_helper'

RSpec.describe Clin::Text::TableRow do
  def table_double(options)
    double(:table, options.reverse_merge(column_length: {}, update_column_length: true,
                                         separate_blank?: true))
  end

  describe '#each' do
    let(:table) { table_double(column_length: double(:col_length, size: size)) }
    subject { Clin::Text::TableRow.new(table, %w(a b c)) }

    before do
      allow(Clin::Text::TableCell).to receive(:new) do |_table, _index, val|
        val
      end
    end
    context 'when same number of column as cells' do
      let(:size) { 3 }
      it { expect { |b| subject.each(&b) }.to yield_control.exactly(size).times }
      it { expect { |b| subject.each(&b) }.to yield_successive_args('a', 'b', 'c') }
    end

    context 'when there are more column that cells in the rows' do
      let(:size) { 5 }
      it { expect { |b| subject.each(&b) }.to yield_control.exactly(size).times }
      it { expect { |b| subject.each(&b) }.to yield_successive_args('a', 'b', 'c', '', '') }
    end
  end

  describe '#border' do
    let(:table) { table_double(vertical_border: '|', border?: border) }
    subject { Clin::Text::TableRow.new(table, []) }
    context 'when border is enabled' do
      let(:border) { true }

      it { expect(subject.border('value')).to eq('|value|') }
      it { expect(subject.border('value', ' ')).to eq('| value |') }
    end

    context 'when border is not enabled' do
      let(:border) { false }

      it { expect(subject.border('value')).to eq('value') }
      it { expect(subject.border('value', ' ')).to eq('value') }
    end
  end

  describe '#to_s' do
    let(:table) { Clin::Text::Table.new(col_delim: delimiter, border: border) }
    subject { Clin::Text::TableRow.new(table, %w(val1 val2 val3)) }

    context 'when no border' do
      let(:border) { false }
      let(:delimiter) { ' [] ' }

      it { expect(subject.to_s).to eq('val1 [] val2 [] val3') }
    end

    context 'when border' do
      let(:border) { true }
      let(:delimiter) { ' [] ' }

      it { expect(subject.to_s).to eq('| val1 [] val2 [] val3 |') }
    end

    context 'when no border and specific delimiter' do
      let(:border) { false }
      let(:delimiter) { [' # ', ' $ '] }

      it { expect(subject.to_s).to eq('val1 # val2 $ val3') }
    end
  end
end
