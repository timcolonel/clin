RSpec.describe Clin::CommandMixin::Core do
  def new_subject
    a = Class.new
    a.include Clin::CommandMixin::Core
    a
  end

  describe '.prioritize' do
    subject { new_subject }
    it 'set priority to 1 when no argument given' do
      subject.prioritize
      expect(subject._priority).to be 1
    end

    it 'set priority to 1 when no argument given' do
      subject.prioritize(42)
      expect(subject._priority).to be 42
    end
  end

  describe '.priority' do
    subject { new_subject }
    it 'get the default priority' do
      expect(subject.priority).to be subject._default_priority
    end

    it 'sum default and priority when subject has been prioritize' do
      subject.prioritize(42)
      expect(subject.priority).to be subject._default_priority + 42
    end

    it 'has a smaller priority when inheriting' do
      child = Class.new(subject)
      expect(child.priority).to be < subject.priority
    end
  end
end
