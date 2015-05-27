require 'spec_helper'

RSpec.describe Clin::CommandDispatcher do
  describe '#initialize' do
    before :all do
      @cmd1 = Class.new(Clin::Command)
      @cmd2 = Class.new(Clin::Command)
      @cmd3 = Class.new(Clin::Command)
    end

    before do
      allow(Clin::Command).to receive(:subclasses).and_return([@cmd1, @cmd2, @cmd3])
    end

    context 'when no argument given' do
      subject { Clin::CommandDispatcher.new }
      it { expect(subject.commands.size).to be 3 }
      it { expect(subject.commands).to include(@cmd1) }
      it { expect(subject.commands).to include(@cmd2) }
      it { expect(subject.commands).to include(@cmd3) }
    end

    context 'when 1 command is given' do
      subject { Clin::CommandDispatcher.new(@cmd3) }
      it { expect(subject.commands.size).to be 1 }
      it { expect(subject.commands).to include(@cmd3) }
    end


    context 'when 2 command is given' do
      subject { Clin::CommandDispatcher.new(@cmd1, @cmd2) }
      it { expect(subject.commands.size).to be 2 }
      it { expect(subject.commands).to include(@cmd1) }
      it { expect(subject.commands).to include(@cmd2) }
    end

    context 'when array of  command is given' do
      subject { Clin::CommandDispatcher.new([@cmd1, @cmd2]) }
      it { expect(subject.commands.size).to be 2 }
      it { expect(subject.commands).to include(@cmd1) }
      it { expect(subject.commands).to include(@cmd2) }
    end
  end

  describe '#parse' do
    let(:cmd1) { double(:command, parse: 'cmd1', usage: 'cmd1 use') }
    let(:cmd2) { double(:command, parse: 'cmd2', usage: 'cmd1 use') }
    let(:args) { %w(some args) }
    subject { Clin::CommandDispatcher.new(cmd1, cmd2) }
    context 'when first command match' do
      before do
        subject.parse(args)
      end
      it { expect(cmd1).to have_received(:parse).with(args, raise_fixed: true) }
      it { expect(subject.parse).to eq('cmd1') }
    end

    context 'when first command return FixedArgumentError' do
      before do
        allow(cmd1).to receive(:parse) { fail Clin::FixedArgumentError, :some }
        subject.parse(args)
      end
      it { expect(cmd1).to have_received(:parse).with(args, raise_fixed: true) }
      it { expect(cmd2).to have_received(:parse).with(args, raise_fixed: true) }
      it { expect(subject.parse).to eq('cmd2') }
    end

    context 'when first command return ArgumentError' do
      before do
        allow(cmd1).to receive(:parse) { fail Clin::ArgumentError, :some }
        allow(cmd2).to receive(:parse) { fail Clin::ArgumentError, :some }
        begin
          subject.parse(args)
        rescue Clin::CommandLineError => e
          @error = e
        end
      end
      it { expect { subject.parse }.to raise_error(Clin::CommandLineError) }
      it { expect(cmd1).to have_received(:parse).with(args, raise_fixed: true) }
      it { expect(cmd2).to have_received(:parse).with(args, raise_fixed: true) }
      it { expect(@error.to_s).to eq(subject.help_message) }
    end
  end
end