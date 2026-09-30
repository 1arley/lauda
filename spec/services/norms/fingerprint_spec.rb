require 'rails_helper'

RSpec.describe Norms::Fingerprint do
  describe '.call' do
    it 'is independent of hash key order' do
      first = described_class.call('scores' => [{ 'raw' => 1, 'valid' => false }])
      second = described_class.call('scores' => [{ 'valid' => false, 'raw' => 1 }])

      expect(first).to eq(second)
    end

    it 'preserves false as distinct from nil' do
      expect(described_class.call('valid' => false)).not_to eq(described_class.call('valid' => nil))
    end
  end
end
