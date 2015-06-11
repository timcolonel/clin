require 'spec_helper'

RSpec.describe Clin::Text::TableSeparatorRow do
  def table_double(options)
    double(:table, options.reverse_merge(column_length: {}, update_column_length: true))
  end


  describe '#delimiter_at' do
    let(:size) { 4 } # 4 columns(i.e. 3 Delimiters)
    let(:table) do
      table_double(column_length: double(:col_length, size: size),
                   column_delimiters: delimiter)
    end

    subject { Clin::Text::TableSeparatorRow.new(table, '-', col_delimiter: include_column) }
    context 'when not include column delimiter' do
      let(:include_column) { false }
      let(:delimiter) { ' | ' }

      it { expect(subject.delimiter_at(0)).to eq('---') }
      it { expect(subject.delimiter_at(1)).to eq('---') }
      it { expect(subject.delimiter_at(2)).to eq('---') }
      it { expect(subject.delimiter_at(3)).to eq('') }
      it { expect(subject.delimiter_at(10)).to eq('') }

    end
    context 'when include column delimiter' do
      let(:include_column) { true }

      context 'when column delimiter is a global value' do
        let(:delimiter) { ' # ' }
        it { expect(subject.delimiter_at(0)).to eq(delimiter) }
        it { expect(subject.delimiter_at(1)).to eq(delimiter) }
        it { expect(subject.delimiter_at(2)).to eq(delimiter) }
        it { expect(subject.delimiter_at(3)).to eq('') }
        it { expect(subject.delimiter_at(10)).to eq('') }
      end

      context 'when column delimiter is a specific' do
        let(:delimiter) { [' # ', ' | ', ' [] '] }
        it { expect(subject.delimiter_at(0)).to eq(delimiter[0]) }
        it { expect(subject.delimiter_at(1)).to eq(delimiter[1]) }
        it { expect(subject.delimiter_at(2)).to eq(delimiter[2]) }
        it { expect(subject.delimiter_at(3)).to eq('') }
        it { expect(subject.delimiter_at(10)).to eq('') }
      end
    end
  end

  describe '#to_s' do
    let(:delimiter) { ' | ' }
    let(:table) do
      Clin::Text::Table.new(col_delim: delimiter, border: border) do |t|
        t.column_length = [4, 4, 4]
      end
    end
    subject { Clin::Text::TableSeparatorRow.new(table, col_delimiter: include_column) }

    context 'when not including column delimiter' do
      let(:include_column) { false }
      let(:border) { false }

      it { expect(subject.to_s).to eq('------------------') }
    end

    context 'when including column delimiter' do
      let(:include_column) { true }
      let(:border) { false }

      it { expect(subject.to_s).to eq('---- | ---- | ----') }
    end

    context 'when border' do
      let(:include_column) { true }
      let(:border) { true }

      it { expect(subject.to_s).to eq('|----- | ---- | -----|') }
    end
  end
end
