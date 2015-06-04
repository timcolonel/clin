require 'spec_helper'
require 'examples/auto_option'

RSpec.describe 'auto_option.rb' do
  suppress_puts
  it { expect(AutoOptionCommand.parse('-e Lorem').params).to eq(echo: 'Lorem') }
  it { expect(AutoOptionCommand.parse('--eko Lorem').params).to eq(echo: 'Lorem') }
  it { expect(AutoOptionCommand.parse('--eko="Lorem ipsum"').params).to eq(echo: 'Lorem ipsum') }

  it { expect { AutoOptionCommand.parse('--echo Value').params }.to raise_error(Clin::HelpError) }
end
