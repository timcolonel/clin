require 'spec_helper'
require 'examples/simple'

RSpec.describe 'simple_spec.rb' do
  suppress_puts
  it { expect(SimpleCommand.parse('display Some').params).
    to eq(display: 'display', message: 'Some') }
  it { expect(SimpleCommand.parse('display "Message with spaces"').params).
    to eq(display: 'display', message: 'Message with spaces') }

  it { expect(SimpleCommand.parse('display Some -e More').params).
    to eq(display: 'display', message: 'Some', echo: 'More') }

  it { expect(SimpleCommand.parse('display Some -eMore').params).
    to eq(display: 'display', message: 'Some', echo: 'More') }

  it { expect(SimpleCommand.parse('display Some -e "Even More"').params).
    to eq(display: 'display', message: 'Some', echo: 'Even More') }

  it { expect(SimpleCommand.parse('display Some --echo More').params).
    to eq(display: 'display', message: 'Some', echo: 'More') }

  it { expect(SimpleCommand.parse('display Some --echo=More').params).
    to eq(display: 'display', message: 'Some', echo: 'More') }

  it { expect(SimpleCommand.parse('display Some --echo "Even More"').params).
    to eq(display: 'display', message: 'Some', echo: 'Even More') }

  it { expect { SimpleCommand.parse('').params }.to raise_error(Clin::HelpError) }
  it { expect { SimpleCommand.parse('-h').params }.to raise_error(Clin::HelpError) }
end
