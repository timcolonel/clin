require 'spec_helper'
require 'examples/list_option'

RSpec.describe 'list_option.rb' do
  suppress_puts
  it { expect(ListCommand.parse('').params).to eq(echo: [], line: 0) }
  it { expect(ListCommand.parse('--echo msg').params).to eq(echo: ['msg'], line: 0) }
  it { expect(ListCommand.parse('--line').params).to eq(echo: [], line: 1) }
  it { expect(ListCommand.parse('--line --line').params).to eq(echo: [], line: 2) }
  it { expect(ListCommand.parse('-lll').params).to eq(echo: [], line: 3) }
  it do
    expect(ListCommand.parse('--echo msg1 --echo msg2').params)
      .to eq(echo: %w(msg1 msg2), line: 0)
  end

  it do
    expect(ListCommand.parse('--echo msg1 --line --echo msg2 -ll').params)
      .to eq(echo: %w(msg1 msg2), line: 3)
  end
end
