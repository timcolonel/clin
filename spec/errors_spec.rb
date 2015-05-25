require 'spec_helper'

RSpec.describe Clin::Error do
  describe Clin::MissingArgumentError do
    let(:arg) { Faker::Lorem.name }
    it { expect(Clin::MissingArgumentError.new(arg).to_s).to eq("Missing argument #{arg}") }
  end
end
