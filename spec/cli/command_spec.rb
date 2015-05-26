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
        subject.exe_name = exe
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

      it { expect(subject.banner).to eq("Usage: command #{arguments} [Options]") }
    end
  end

  describe '#parse_arguments' do
    subject { Class.new(Clin::Command) }
    let(:args) { %w(fix <var> [opt]) }

    before do
      subject.arguments(args)
    end

    it 'raise argument when fixed in different' do
      expect { subject.parse_arguments(%w(other val opt)) }.to raise_error(Clin::CommandLineError)
    end
    it 'raise error when too few arguments' do
      expect { subject.parse_arguments(['fix']) }.to raise_error(Clin::CommandLineError)
    end
    it 'raise error when too much argument' do
      expect { subject.parse_arguments(%w(other val opt more)) }
          .to raise_error(Clin::CommandLineError)
    end

    it 'map arguments' do
      expect(subject.parse_arguments(%w(fix val opt))).to eq(fix: 'fix', var: 'val', opt: 'opt')
    end

    it 'opt argument is nil when not provided' do
      expect(subject.parse_arguments(%w(fix val))).to eq(fix: 'fix', var: 'val')
    end
  end

  describe '#parse_options' do
    subject { Class.new(Clin::Command) }
    let(:opt1) { Clin::Option.new(:name, '-n', '--name Name', 'Set name') }
    let(:opt2) { Clin::Option.new(:verbose, '-v', '--verbose', 'Set verbose') }
    let(:opt3) { Clin::Option.new(:echo, '-e', '--echo [ECHO]', 'Set name') }
    before do
      subject.add_option opt1
      subject.add_option opt2
      subject.add_option opt3
    end

    it 'raise argument when option value is missing' do
      expect { subject.parse_options(%w(--name)) }.to raise_error(OptionParser::MissingArgument)
    end
    it 'raise error when unknown option' do
      expect { subject.parse_options(%w(--other)) }.to raise_error(OptionParser::InvalidOption)
    end

    it { expect(subject.parse_options(%w(--name MyName))).to eq(name: 'MyName') }
    it { expect(subject.parse_options(%w(--name=MyName))).to eq(name: 'MyName') }
    it { expect(subject.parse_options(%w(-nMyName))).to eq(name: 'MyName') }


    it { expect(subject.parse_options(%w(-v))).to eq(verbose: true) }

    it { expect(subject.parse_options(%w(--echo))).to eq(echo: nil) }
    it { expect(subject.parse_options(%w(-e EchoThis))).to eq(echo: 'EchoThis') }
  end

  describe '.handle_dispatch' do
    subject { Class.new(Clin::Command) }
    let(:args) { [Faker::Lorem.word, Faker::Lorem.word] }
    before do
      subject.arguments(%w(remote <args>...))
    end

    context 'when only dispatching arguments' do
      before do
        subject.dispatch :args
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:parse)
      end
      it 'call the command dispatcher with the right arguments' do
        expect_any_instance_of(Clin::CommandDispatcher).to receive(:parse).once.with(args)
        subject.handle_dispatch(remote: 'remote', args: args)
      end
    end

    context 'when using prefix' do
      let(:prefix) { 'remote' }
      before do
        subject.dispatch :args, prefix: prefix
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:parse)
      end
      it 'call the command dispatcher with the right arguments' do
        expect_any_instance_of(Clin::CommandDispatcher).to receive(:parse).once.with([prefix] + args)
        subject.handle_dispatch(remote: 'remote', args: args)
      end
    end

    context 'when using commands' do
      let(:cmd1) { double(:command) }
      let(:cmd2) { double(:command) }
      before do
        subject.dispatch :args, commands: [cmd1, cmd2]
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:initialize)
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:parse)
      end
      it 'call the command dispatcher with the right arguments' do
        expect_any_instance_of(Clin::CommandDispatcher).to receive(:initialize).once.with([cmd1, cmd2])
        subject.handle_dispatch(remote: 'remote', args: args)
      end
    end
  end
end
