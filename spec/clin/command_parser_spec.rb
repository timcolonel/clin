require 'spec_helper'

RSpec.describe Clin::CommandParser do
  describe '#parse_options' do
    before :all do
      @command = Class.new(Clin::Command)
      @command.add_option Clin::Option.new(:name, 'Set name')
      @command.add_option Clin::Option.new(:verbose, 'Set verbose', argument: false)
      @command.add_option Clin::Option.new(:echo, 'Set name', argument_optional: true)
    end

    subject { Clin::CommandParser.new(@command, []) }

    it 'raise argument when option value is missing' do
      subject.parse_options(%w(--name))
      expect(subject.valid?).to be false
      expect(subject.errors.first).to be_a(Clin::MissingOptionArgumentError)
    end

    it 'add error when unknown option' do
      subject.parse_options(%w(--other))
      expect(subject.errors.size).to be 1
      expect(subject.errors.first).to be_a(Clin::OptionError)
    end

    it { expect(subject.parse_options(%w(--name MyName))).to eq(name: 'MyName') }
    it { expect(subject.parse_options(%w(--name=MyName))).to eq(name: 'MyName') }
    it { expect(subject.parse_options(%w(-nMyName))).to eq(name: 'MyName') }


    it { expect(subject.parse_options(%w(-v))).to eq(verbose: true) }

    it { expect(subject.parse_options(%w(--echo))).to eq(echo: true) }
    it { expect(subject.parse_options(%w(-e EchoThis))).to eq(echo: 'EchoThis') }
  end


  describe '#parse_arguments' do
    before :all do
      @command = Class.new(Clin::Command)
      @command.arguments(%w(fix <var> [opt]))
    end

    subject { Clin::CommandParser.new(@command, []) }

    it 'raise argument when fixed in different' do
      subject.parse_arguments(%w(other val opt))
      expect(subject.valid?).to be false
      expect(subject.errors.first).to be_a Clin::CommandLineError
    end

    it 'raise error when too few arguments' do
      subject.parse_arguments(%w(fix))
      expect(subject.valid?).to be false
      expect(subject.errors.first).to be_a Clin::CommandLineError
    end

    it 'raise error when too much argument' do
      subject.parse_arguments(%w(other val opt more))
      expect(subject.valid?).to be false
      expect(subject.errors.first).to be_a Clin::CommandLineError
    end

    it 'map arguments' do
      expect(subject.parse_arguments(%w(fix val opt))).to eq(fix: 'fix', var: 'val', opt: 'opt')
    end

    it 'opt argument is nil when not provided' do
      expect(subject.parse_arguments(%w(fix val))).to eq(fix: 'fix', var: 'val')
    end
  end

  describe '.handle_dispatch' do
    let(:args) { [Faker::Lorem.word, Faker::Lorem.word] }
    before :all do
      @command = Class.new(Clin::Command)
      @command.arguments(%w(remote <args>...))
    end

    before do
      allow_any_instance_of(Clin::CommandDispatcher).to receive(:parse)
    end

    subject { Clin::CommandParser.new(@command, []) }

    context 'when only dispatching arguments' do
      before do
        @command.dispatch :args
      end
      it 'call the command dispatcher with the right arguments' do
        expect_any_instance_of(Clin::CommandDispatcher).to receive(:parse).once.with(args)
        subject.redispatch(remote: 'remote', args: args)
      end
    end

    context 'when using prefix' do
      let(:prefix) { 'remote' }
      before do
        @command.dispatch :args, prefix: prefix
      end
      it 'call the command dispatcher with the right arguments' do
        expect_any_instance_of(Clin::CommandDispatcher).to receive(:parse).once.with([prefix] + args)
        subject.redispatch(remote: 'remote', args: args)
      end
    end

    context 'when using commands' do
      let(:cmd1) { double(:command_mixin) }
      let(:cmd2) { double(:command_mixin) }
      let(:dispatcher) { double(:dispatcher, parse: true) }
      before do
        @command.dispatch :args, commands: [cmd1, cmd2]
      end

      it 'call the command dispatcher with the right arguments' do
        expect(Clin::CommandDispatcher)
          .to receive(:new).once.with([cmd1, cmd2]).and_return(dispatcher)
        subject.redispatch(remote: 'remote', args: args)
      end
    end

    context 'when dispatcher raise HelpError' do
      let(:new_message) { Faker::Lorem.sentence }
      before do
        @command.dispatch :args
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:new)
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:parse) do
          fail Clin::HelpError, 'Dispatcher error'
        end
        allow(@command).to receive(:help).and_return(new_message)
      end
      it do
        expect { subject.redispatch(remote: 'remote', args: args) }
          .to raise_error(Clin::HelpError)
      end
      it do
        expect { subject.redispatch(remote: 'remote', args: args) }.to raise_error(new_message)
      end
    end
  end
end
