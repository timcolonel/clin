require 'spec_helper'
require 'examples/reusable_options'

RSpec.describe 'reusable_options.rb' do
  def parse(str)
    ReusableOptionCommand.parse(str).params
  end

  suppress_puts
  it { expect(parse('--verbose')).to eq(verbose: true) }
  it { expect(parse('--echo "Hello world!"')).to eq(echo: 'Hello world!') }
  it { expect(parse('--source "~/source"')).to eq(source: '~/source') }
  it { expect(parse('--echo "Hello world!" --source "~/source"'))
         .to eq(echo: 'Hello world!', source: '~/source') }
  it { expect(parse('--source "~/source" -v --echo "Hello world!"'))
         .to eq(echo: 'Hello world!', verbose: true, source: '~/source') }
  it { expect(parse('-s"~/source" -v --echo "Hello world!"'))
         .to eq(echo: 'Hello world!', verbose: true, source: '~/source') }


end
