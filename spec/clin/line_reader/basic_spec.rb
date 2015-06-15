require 'spec_helper'

describe Clin::LineReader::Basic do
  let(:shell) { Clin::Shell.new }
  describe '#readline' do
    it 'uses $stdin and $stdout to get input from the user' do
      expect(shell.out).to receive(:print).with('Where are you from? ')
      expect(shell.in).to receive(:gets).and_return('France')
      expect(shell.in).not_to receive(:noecho)
      reader = Clin::LineReader::Basic.new(shell, 'Where are you from? ', {})
      expect(reader.readline).to eq('France')
    end

    it 'disables echo when asked to' do
      expect(shell.out).to receive(:print).with('Where are you from? ')
      noecho_stdin = double('noecho_stdin')
      expect(noecho_stdin).to receive(:gets).and_return('Asgard')
      expect(shell.in).to receive(:noecho).and_yield(noecho_stdin)
      reader = Clin::LineReader::Basic.new(shell, 'Where are you from? ', echo: false)
      expect(reader.readline).to eq('Asgard')
    end
  end

  describe '.available?' do
    it 'returns is always available' do
      expect(Clin::LineReader::Basic).to be_available
    end
  end

  describe '#scan' do
    it 'call in#gets when echo is true' do
      reader = Clin::LineReader::Basic.new(shell, 'Where are you from? ', {echo: true})
      expect(shell.in).to receive(:gets)
      expect(shell.in).not_to receive(:noecho)
      reader.send(:scan)
    end

    it 'call in#noecho(&:gets) when echo is false' do
      reader = Clin::LineReader::Basic.new(shell, 'Where are you from? ', {echo: false})
      expect(shell.in).not_to receive(:gets)
      expect(shell.in).to receive(:noecho)
      reader.send(:scan)
    end

    it 'call in#gets if the console does not support noecho' do
      reader = Clin::LineReader::Basic.new(shell, 'Where are you from? ', {echo: false})
      expect(shell.in).to receive(:noecho) do
        fail Errno::EBADF
      end
      expect(shell.in).to receive(:gets)
      reader.send(:scan)
    end
  end
end
