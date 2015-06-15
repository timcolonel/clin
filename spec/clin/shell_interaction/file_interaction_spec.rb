require 'clin'

RSpec.describe Clin::ShellInteraction::FileConflict do
  let(:shell) { Clin::Shell.new }
  subject { Clin::ShellInteraction::FileConflict.new(shell) }

  describe 'show_diff' do
    it 'open a tmp file' do
      file = double(:file, path: 'tmp/filename.txt')
      expect(file).to receive(:write).with('new_content')
      expect(file).to receive(:rewind)
      expect(Tempfile).to receive(:open).with('filename.txt').and_yield(file)
      expect_any_instance_of(Kernel)
        .to receive(:system).with('diff -u "path/filename.txt" "tmp/filename.txt"')
      subject.send(:show_diff, 'path/filename.txt', 'new_content')
    end
  end
end
