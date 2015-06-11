require 'spec_helper'

RSpec.describe Clin::Text do
  describe '#process_line' do
    let (:line) { Faker::Lorem::sentence }
    context 'when global indent is not set' do
      subject { Clin::Text.new }

      it 'return the same line with no indent' do
        expect(subject.process_line(line)).to eq(line)
      end

      it 'add a new line and indent' do
        expect(subject.process_line(line, indent: 2)).to eq("  #{line}")
      end
    end

    context 'when global indent is set' do
      subject { Clin::Text.new(indent: '**') }

      it 'add line with global indent' do
        expect(subject.process_line(line)).to eq("**#{line}")
      end

      it 'add line with global indent and method indent' do
        expect(subject.process_line(line, indent: 2)).to eq("**  #{line}")
      end
    end
  end

  describe '#line' do
    let (:line1) { Faker::Lorem::sentence }
    let (:line2) { Faker::Lorem::sentence }

    before do
      subject.line(line1)
      subject.line(line2)
    end

    it { expect(subject.lines.size).to be 2 }
    it { expect(subject.lines[0]).to eq line1 }
    it { expect(subject.lines[1]).to eq line2 }
  end

  describe '#prefix' do
    let (:line1) { Faker::Lorem::sentence }
    let (:line2) { Faker::Lorem::sentence }

    before do
      subject.line(line1)
      subject.prefix(line2)
    end

    it { expect(subject.lines.size).to be 2 }
    it { expect(subject.lines[0]).to eq line2 }
    it { expect(subject.lines[1]).to eq line1 }
  end

  describe '#blank' do
    it 'add 1 blank line' do
      subject.blank
      expect(subject.lines).to eq([''])
    end

    it 'add multiple blank line' do
      subject.blank(3)
      expect(subject.lines).to eq(['', '', ''])
    end
  end

  describe '#lines' do
    let (:lines) { [Faker::Lorem::sentence, Faker::Lorem::sentence] }
    it 'add lines' do
      subject.lines(lines)
      expect(subject.lines).to eq(lines)
    end

    it 'add lines and indent' do
      subject.lines(lines, indent: '**')
      expect(subject.lines).to eq(lines.map { |x| "**#{x}" })
    end
  end

  describe '#text' do
    let (:lines) { [Faker::Lorem::sentence, Faker::Lorem::sentence] }

    let (:text) do
      text_lines = lines
      Clin::Text.new do |t|
        t.lines(text_lines)
      end
    end

    it 'add text' do
      subject.text(text)
      expect(subject.lines).to eq(lines)
    end

    it 'add text and indent' do
      subject.text(text, indent: '**')
      expect(subject.lines).to eq(lines.map { |x| "**#{x}" })
    end
  end

  describe '#indent' do
    let (:line) { Faker::Lorem::sentence }

    it 'add an indented line inside block' do
      subject.indent 2 do
        subject.line(line)
      end
      expect(subject.lines).to eq(["  #{line}"])
    end

    it 'add line with nested indent' do
      subject.indent 2 do
        subject.line(line)
        subject.indent '***' do
          subject.line(line)
        end
        subject.line(line)
      end
      expect(subject.lines).to eq(["  #{line}", "  ***#{line}", "  #{line}"])
    end
  end


  describe '#to_s' do
    let (:line1) { Faker::Lorem::sentence }
    let (:line2) { Faker::Lorem::sentence }
    let (:line3) { Faker::Lorem::sentence }

    it 'join line with \n' do
      subject.line line1
      subject.line line2
      subject.prefix line3
      expect(subject.to_s).to eq("#{line3}\n#{line1}\n#{line2}\n")
    end
  end
end
