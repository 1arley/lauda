require 'rails_helper'

RSpec.describe Patient, type: :model do
  subject { build(:patient) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to belong_to(:tenant) }
  end

  describe '#age' do
    it 'calculates age from birth_date' do
      patient = build(:patient, birth_date: 10.years.ago.to_date)
      expect(patient.age).to eq(10)
    end

    it 'returns nil when birth_date is nil' do
      patient = build(:patient, birth_date: nil)
      expect(patient.age).to be_nil
    end
  end
end
