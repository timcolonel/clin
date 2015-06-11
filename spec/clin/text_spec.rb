require 'spec_helper'

RSpec.describe Clin::Text do
  describe '#line' do
    let (:line) { Faker::Lorem::sentence }
    context 'when global indent is not set' do
      subject { Clin::Text.new }

      it 'add only 1 line' do
        subject.line(line)
        expect(subject.lines.size).to be 1
      end

      it 'add a new line' do
        subject.line(line)
        expect(subject.lines.first).to eq(line)
      end

      it 'add a new line and indent' do
        subject.line(line, indent: 2)
        expect(subject.lines.first).to eq("  #{line}")
      end
    end

    context 'when global indent is set' do
      subject { Clin::Text.new(indent: '**') }

      it 'add line with global indent' do
        subject.line(line)
        expect(subject.lines.first).to eq("**#{line}")
      end

      it 'add line with global indent and method indent' do
        subject.line(line, indent: 2)
        expect(subject.lines.first).to eq("**  #{line}")
      end
    end
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

    it 'join line with \n' do
      subject.line line1
      subject.line line2
      expect(subject.to_s).to eq("#{line1}\n#{line2}\n")
    end
  end
end
