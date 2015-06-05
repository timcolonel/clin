require 'spec_helper'
require 'clin/command'

RSpec.describe Clin::Command do
  describe '#arguments=' do
    subject { Class.new(Clin::Command) }
    let(:args) { %w(fix <var> [opt]) }
    before do
      allow(Clin::Argument).to receive(:new)
    end
    context 'when using string to set arguments' do
      before do
        subject.arguments (args.join(' '))
      end
      it { expect(subject.args.size).to eq(args.size) }
      it { expect(Clin::Argument).to have_received(:new).exactly(args.size).times }
    end

    context 'when using array to set arguments' do
      before do
        subject.arguments (args)
      end
      it { expect(subject.args.size).to eq(args.size) }
      it { expect(Clin::Argument).to have_received(:new).exactly(args.size).times }
    end

    context 'when using array that contains multiple arguments to set arguments' do
      before do
        subject.arguments ([args[0], args[1..-1]])
      end
      it { expect(subject.args.size).to eq(args.size) }
      it { expect(Clin::Argument).to have_received(:new).exactly(args.size).times }
    end

  end

  describe '#banner' do
    subject { Class.new(Clin::Command) }
    context 'when exe is defined' do
      let(:exe) { Faker::Lorem.word }
      before do
        subject.exe_name(exe)
      end

      it { expect(subject.banner).to eq("Usage: #{exe} [Options]") }
    end

    context 'when exe is not defined' do
      it { expect(subject.banner).to eq('Usage: command [Options]') }
    end

    context 'when arguments are defined' do
      let(:arguments) { '<some> [Value]' }
      before do
        subject.arguments(arguments)
      end

      it { expect(subject.banner).to eq("Usage: #{Clin.default_exe_name} #{arguments} [Options]") }
    end
  end



  describe '.dispatch_doc' do
    subject { Class.new(Clin::Command) }
    before do
      subject.arguments(%w(remote <args>...))
    end

    let(:cmd1) { double(:command_mixin, usage: 'cmd1') }
    let(:cmd2) { double(:command_mixin, usage: 'cmd2') }
    let(:cmd3) { double(:command_mixin, usage: 'cmd3') }
    let(:cmds) { [cmd1, cmd2, cmd3] }
    let(:opts) { double(:option_parser, separator: true) }
    before do
      subject.dispatch :args, commands: cmds
      allow_any_instance_of(Clin::CommandDispatcher).to receive(:initialize)
      subject.dispatch_doc(opts)
    end
    it { expect(opts).to have_received(:separator).at_least(cmds.size).times }
  end

  describe '.subcommands' do
    before do
      @cmd1 = Class.new(Clin::Command)
      @cmd2 = Class.new(Clin::Command)
      @abstract_cmd = Class.new(Clin::Command) { abstract true }
    end

    it { expect(Clin::Command.subcommands).to include(@cmd1) }
    it { expect(Clin::Command.subcommands).to include(@cmd2) }
    it { expect(Clin::Command.subcommands).not_to include(@abstract_cmd) }
  end

  describe '.exe_name' do
    context 'when not setting the exe_name' do
      subject { Class.new(Clin::Command) }

      it { expect(subject.exe_name).to eq(Clin.exe_name) }
    end

    context 'when setting the exe_name' do
      let(:name) { Faker::Lorem.word }
      subject { Class.new(Clin::Command) }
      before do
        subject.exe_name(name)
      end
      it { expect(subject.exe_name).to eq(name) }
    end
  end

end
