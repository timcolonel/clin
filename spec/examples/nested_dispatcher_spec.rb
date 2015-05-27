require 'spec_helper'
require 'examples/nested_dispatcher'

RSpec.describe 'nested_dispatcher.rb' do
  suppress_puts
  it { expect(DispatchCommand.parse('you display Some').params).
      to eq(you: 'you', display: 'display', message: 'Some') }

  it { expect(DispatchCommand.parse('you display Some -e More').params).
      to eq(you: 'you', display: 'display', message: 'Some', echo: 'More') }

  it { expect(DispatchCommand.parse('you display Some -e More --times 3').params).
      to eq(you: 'you', display: 'display', message: 'Some', echo: 'More', times: 3) }

  it { expect(DispatchCommand.parse('you display Some -e More --times 3 -v').params).
      to eq(you: 'you', display: 'display', message: 'Some', echo: 'More', times: 3) }

  it { expect(DispatchCommand.parse('you display Some --verbose -e More --times 3').params).
      to eq(you: 'you', display: 'display', message: 'Some', echo: 'More', times: 3) }

  it {
    expect(DispatchCommand.parse('you  --verbose display Some -e More --times 3').params).
        to eq(you: 'you', display: 'display', message: 'Some', echo: 'More', times: 3) }
  it { expect { DispatchCommand.parse('').params }.to raise_error(Clin::HelpError) }
  it { expect { DispatchCommand.parse('-h').params }.to raise_error(Clin::HelpError) }
end