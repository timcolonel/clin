require 'spec_helper'

RSpec.describe Clin::CommandParser do
  describe '#parse_options' do
    before :all do
      @command = Class.new(Clin::Command)
      @command.add_option Clin::Option.new(:name, 'Set name')
      @command.add_option Clin::Option.new(:verbose, 'Set verbose', argument: false)
      @command.add_option Clin::Option.new(:echo, 'Set name', optional_argument: true)
    end

    subject { Clin::CommandParser.new(@command, []) }

    it 'raise argument when option value is missing' do
      expect { subject.parse_options(%w(--name)) }.to raise_error(OptionParser::MissingArgument)
    end
    it 'raise error when unknown option' do
      expect { subject.parse_options(%w(--other)) }.to raise_error(Clin::OptionError)
    end

    it { expect(subject.parse_options(%w(--name MyName))).to eq(name: 'MyName') }
    it { expect(subject.parse_options(%w(--name=MyName))).to eq(name: 'MyName') }
    it { expect(subject.parse_options(%w(-nMyName))).to eq(name: 'MyName') }


    it { expect(subject.parse_options(%w(-v))).to eq(verbose: true) }

    it { expect(subject.parse_options(%w(--echo))).to eq(echo: nil) }
    it { expect(subject.parse_options(%w(-e EchoThis))).to eq(echo: 'EchoThis') }
  end


  describe '#parse_arguments' do
    before :all do
      @command = Class.new(Clin::Command)
      @command.arguments(%w(fix <var> [opt]))
    end

    subject { Clin::CommandParser.new(@command, []) }

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

  describe '#skipped_options' do
    def skipped_options(argv)
      Clin::CommandParser.new(@command, argv).skipped_options
    end

    before :all do
      @command = Class.new(Clin::Command)
      @command.skip_options true
    end

    context 'when all options should be skipped' do
      it { expect(skipped_options(%w(pos arg))).to eq([]) }

      it { expect(skipped_options(%w(pos arg --ignore -t))).to eq(%w(--ignore -t)) }

      it { expect(skipped_options(%w(pos arg --ignore value -t))).to eq(%w(--ignore value -t)) }

    end
    context 'when option are define they should not be skipped' do
      before :all do
        @command.flag_option :verbose, 'Verbose'
      end

      it { expect(skipped_options(%w(pos arg --ignore value -t -v))).to eq(%w(--ignore value -t)) }

      it do
        expect(skipped_options(%w(pos arg --verbose --ignore value -t)))
          .to eq(%w(--ignore value -t))
      end

      it do
        expect(skipped_options(%w(pos arg --ignore value --verbose -t)))
          .to eq(%w(--ignore value -t))
      end
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
        subject.handle_dispatch(remote: 'remote', args: args)
      end
    end

    context 'when using prefix' do
      let(:prefix) { 'remote' }
      before do
        @command.dispatch :args, prefix: prefix
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
        @command.dispatch :args, commands: [cmd1, cmd2]
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:initialize)
      end
      it 'call the command dispatcher with the right arguments' do
        expect_any_instance_of(Clin::CommandDispatcher).to receive(:initialize).once.with([cmd1, cmd2])
        subject.handle_dispatch(remote: 'remote', args: args)
      end
    end

    context 'when dispatcher raise HelpError' do
      let(:new_message) { Faker::Lorem.sentence }
      before do
        @command.dispatch :args
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:initialize)
        allow_any_instance_of(Clin::CommandDispatcher).to receive(:parse) do
          fail Clin::HelpError, 'Dispatcher error'
        end
        allow(@command).to receive(:option_parser).and_return(new_message)
      end
      it do
        expect { subject.handle_dispatch(remote: 'remote', args: args) }
          .to raise_error(Clin::HelpError)
      end
      it do
        expect { subject.handle_dispatch(remote: 'remote', args: args) }
          .to raise_error(new_message)
      end
    end
  end
end
