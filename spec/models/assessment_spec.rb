require 'rails_helper'

RSpec.describe Assessment, type: :model do
  subject { build(:assessment) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to belong_to(:patient) }
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:tenant) }
  end

  describe 'statuses' do
    it 'defines the status enum' do
      expect(build(:assessment)).to define_enum_for(:status).with_values(draft: 0, in_progress: 1, review: 2,
                                                                         final: 3, archived: 4)
    end
  end
end
