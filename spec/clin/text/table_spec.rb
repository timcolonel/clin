require 'spec_helper'

RSpec.describe Clin::Text::Table do
  describe '#row' do
    before do
      subject.row(%w(a b c))
      subject.row(%w(a2 b2 c2))
    end

    it { expect(subject.rows.size).to be 2 }
    it { expect(subject.rows.first).to be_a Clin::Text::TableRow }
    it { expect(subject.rows.first.cells.size).to be 3 }
  end

  describe '#header' do
    before do
      subject.header(%w(a b c))
    end

    it { expect(subject.rows).to be_empty }
    it { expect(subject.header).to be_a Clin::Text::TableRow }
    it { expect(subject.header.cells.size).to be 3 }
  end

  describe '#separator' do
    before do
      subject.row(%w(a b c))
      subject.separator
      subject.separator('=')
    end

    it { expect(subject.rows.size).to be 3 }
    it { expect(subject.rows[1]).to be_a Clin::Text::TableSeparatorRow }
    it { expect(subject.rows[2]).to be_a Clin::Text::TableSeparatorRow }
    it { expect(subject.rows[2].char).to eq '=' }
  end

  describe '#align' do
    it 'set global alignment' do
      subject.align(:center)
      expect(subject.alignment).to eq :center
    end

    it 'set column alignment' do
      subject.align(*[:center, :left, :right])
      expect(subject.alignment).to eq [:center, :left, :right]
    end
  end

  describe '#column_delimiter' do
    it 'set global delimiter' do
      subject.column_delimiter(' # ')
      expect(subject.column_delimiters).to eq(' # ')
    end

    it 'set column delimiter' do
      subject.column_delimiter(*[' # ', ' O ', ' [] '])
      expect(subject.column_delimiters).to eq [' # ', ' O ', ' [] ']
    end
  end

  describe '#update_column_length' do
    it 'set the value' do
      subject.update_column_length(1, 12)
      expect(subject.column_length).to eq({1 => 12})
    end

    it 'set overwrite smaller value' do
      subject.update_column_length(1, 12)
      subject.update_column_length(1, 24)
      expect(subject.column_length).to eq({1 => 24})
    end

    it 'set keep larger value' do
      subject.update_column_length(1, 12)
      subject.update_column_length(1, 6)
      expect(subject.column_length).to eq({1 => 12})
    end
  end

  describe '#sym_or_array' do
    it 'return symbol when symbol given' do
      expect(subject.send(:sym_or_array, :sym)).to eq(:sym)
    end

    it 'return array when multiple arguments given' do
      expect(subject.send(:sym_or_array, :sym1, :sym2, :sym3)).to eq([:sym1, :sym2, :sym3])
    end

    it 'return array when array given' do
      expect(subject.send(:sym_or_array, [:sym1, :sym2, :sym3])).to eq([:sym1, :sym2, :sym3])
    end

    it 'return array when array and arguments given' do
      expect(subject.send(:sym_or_array, [:sym1, :sym2], :sym3)).to eq([:sym1, :sym2, :sym3])
    end
  end

  describe '#add_border' do
    let(:text) { double(:text, line: true, prefix: true) }
    let (:line) { '====----====' }
    before do
      allow(Clin::Text::TableSeparatorRow).to receive(:new).and_return(line)
      subject.send(:add_border, text)
    end
    it { expect(text).to have_received(:line).with(line) }
    it { expect(text).to have_received(:prefix).with(line) }
  end

  describe '#to_text' do
    let(:header) { %w(Header1 Header2 Header3) }
    let(:row1) { %w(First1 First2 First3) }
    let(:row2) { %w(Second1 Second2 SecondThird) }

    before do
      subject.border = false
      subject.row row1
      subject.row row2
    end

    it 'make a text with only the given row' do
      expect(subject.to_text._lines.size).to be 2
    end

    it 'add 2 rows for header' do
      subject.header header
      expect(subject.to_text._lines.size).to be 4
    end

    it 'add 2 rows for border' do
      subject.border = true
      expect(subject.to_text._lines.size).to be 4
    end
  end
  describe '#to_s' do
    subject do
      Clin::Text::Table.new(border: false) do |t|
        t.align :right, :center, :left
        # t.column_delimiter ' - ', ' # '
        t.header %w(First Last Email)

        t.row %w(Timothee Guerin timothee.guerin@outlook.com)
        t.row %w(Some Guy Some.Guy@outlook.com)

        t.separator

        t.row %w(VeryLongFirstName Guy Some.Other@outlook.com)
      end
    end

    context 'when include border' do
      it 'build the table' do
        subject.border = true
        expect(subject.to_s).to eq <<table
|----------------------------------------------------------|
|             First |  Last  | Email                       |
|------------------ | ------ | ----------------------------|
|          Timothee | Guerin | timothee.guerin@outlook.com |
|              Some |  Guy   | Some.Guy@outlook.com        |
|------------------ | ------ | ----------------------------|
| VeryLongFirstName |  Guy   | Some.Other@outlook.com      |
|----------------------------------------------------------|
table
      end
    end

    context 'when no border' do
      before do
        subject.border = false
      end

      it 'build the table' do
        out = <<table
            First |  Last  | Email
----------------- | ------ | ---------------------------
         Timothee | Guerin | timothee.guerin@outlook.com
             Some |  Guy   | Some.Guy@outlook.com
----------------- | ------ | ---------------------------
VeryLongFirstName |  Guy   | Some.Other@outlook.com
table
        # Need to rstrip because trailing whitespace are being removed automatically by editor
        expect(subject.to_s.split("\n").map(&:rstrip)).to eq out.split("\n").map(&:rstrip)
      end
    end

    context 'when custom column delimiter' do
      before do
        subject.border = true
        subject.column_delimiter ' - ', ' # '
      end

      it 'build the table' do
        expect(subject.to_s).to eq <<table
|----------------------------------------------------------|
|             First -  Last  # Email                       |
|------------------ - ------ # ----------------------------|
|          Timothee - Guerin # timothee.guerin@outlook.com |
|              Some -  Guy   # Some.Guy@outlook.com        |
|------------------ - ------ # ----------------------------|
| VeryLongFirstName -  Guy   # Some.Other@outlook.com      |
|----------------------------------------------------------|
table
      end
    end

    context 'when align all to the right' do
      before do
        subject.border = true
        subject.align :right
      end

      it 'build the table' do
        expect(subject.to_s).to eq <<table
|----------------------------------------------------------|
|             First |   Last |                       Email |
|------------------ | ------ | ----------------------------|
|          Timothee | Guerin | timothee.guerin@outlook.com |
|              Some |    Guy |        Some.Guy@outlook.com |
|------------------ | ------ | ----------------------------|
| VeryLongFirstName |    Guy |      Some.Other@outlook.com |
|----------------------------------------------------------|
table
      end
    end
  end
end
