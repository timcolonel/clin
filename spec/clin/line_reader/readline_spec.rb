require 'spec_helper'

describe Clin::LineReader::Readline do
  let(:shell) { Clin::Shell.new }
  describe '#readline' do
    it 'call Readline.readline' do
      expect(Readline).to receive(:readline).with('> ', true).and_return('val')
      expect(Readline).not_to receive(:completion_proc=)
      subject = Clin::LineReader::Readline.new(shell, '> ', {})
      expect(subject.readline).to eq('val')
    end

    it 'provides tab completion when given a limited_to option' do
      countries = ['United States', 'France', 'United Kingdom']
      expect(Readline).to receive(:readline)
      expect(Readline).to receive(:completion_proc=) do |proc|
        expect(proc.call('')).to eq countries
        expect(proc.call('U')).to eq ['United States', 'United Kingdom']
        expect(proc.call('United S')).to eq ['United States']
      end

      subject = Clin::LineReader::Readline.new(shell, 'Where are you from? ',
                                               autocomplete: countries)
      subject.readline
    end

    it 'default back to the basic when echo is false' do
      expect(shell.out).to receive(:print).with('Where are you from? ')
      noecho_stdin = double('noecho_stdin')
      expect(noecho_stdin).to receive(:gets).and_return('Asgard')
      expect(shell.in).to receive(:noecho).and_yield(noecho_stdin)
      subject = Clin::LineReader::Readline.new(shell, 'Where are you from? ', echo: false)
      expect(subject.readline).to eq('Asgard')
    end
  end

  describe '.available?' do
    it 'returns is available by default' do
      expect(Clin::LineReader::Readline).to be_available
    end

    it 'returns not available if disable ' do
      allow(Clin).to receive(:use_readline?).and_return(false)
      expect(Clin::LineReader::Readline).not_to be_available
    end
  end

  describe '#autocomplete?' do
    it 'return true if defined' do
      subject = Clin::LineReader::Readline.new(shell, '> ', autocomplete: [''])
      expect(subject.send(:autocomplete?)).to be_truthy
    end

    it 'return false if false' do
      subject = Clin::LineReader::Readline.new(shell, '> ', autocomplete: false)
      expect(subject.send(:autocomplete?)).to be_falsey
    end

    it 'return false if not defined' do
      subject = Clin::LineReader::Readline.new(shell, '> ')
      expect(subject.send(:autocomplete?)).to be_falsey
    end
  end
end
