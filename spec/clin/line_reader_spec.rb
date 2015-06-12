require 'spec_helper'

RSpec.describe Clin::LineReader do
  let(:shell) { Clin::Shell.new }
  it 'use readline when use_readline? is true' do
    expect_any_instance_of(Clin::LineReader::Readline).to receive(:readline)
    expect_any_instance_of(Clin::LineReader::Basic).not_to receive(:readline)
    Clin::LineReader.scan(shell, '> ')
  end

  it 'use basic when use_readline? is false' do
    allow(Clin).to receive(:use_readline?).and_return(false)
    expect_any_instance_of(Clin::LineReader::Readline).not_to receive(:readline)
    expect_any_instance_of(Clin::LineReader::Basic).to receive(:readline)
    Clin::LineReader.scan(shell, '> ')
  end
end
