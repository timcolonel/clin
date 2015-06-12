require 'spec_helper'

describe Clin::LineReader::Basic do
  let(:shell) { Clin::Shell.new }
  describe '#readline' do
    it 'uses $stdin and $stdout to get input from the user' do
      expect(shell.out).to receive(:print).with('Where are you from? ')
      expect(shell.in).to receive(:gets).and_return('France')
      expect(shell.in).not_to receive(:noecho)
      editor = Clin::LineReader::Basic.new(shell, 'Where are you from? ', {})
      expect(editor.readline).to eq('France')
    end

    it 'disables echo when asked to' do
      expect(shell.out).to receive(:print).with('Where are you from? ')
      noecho_stdin = double('noecho_stdin')
      expect(noecho_stdin).to receive(:gets).and_return('Asgard')
      expect(shell.in).to receive(:noecho).and_yield(noecho_stdin)
      editor = Clin::LineReader::Basic.new(shell, 'Where are you from? ', echo: false)
      expect(editor.readline).to eq('Asgard')
    end
  end

  describe '.available?' do
    it 'returns is always available' do
      expect(Clin::LineReader::Basic).to be_available
    end
  end
end
