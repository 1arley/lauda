class Assessment < ApplicationRecord
  include Discard::Model
  include Auditable

  belongs_to :tenant
  belongs_to :patient
  belongs_to :owner, class_name: 'User'
  has_many :instrument_applications, dependent: :destroy
  has_many :reports, dependent: :destroy

  enum :status, { draft: 0, in_progress: 1, review: 2, final: 3, archived: 4 }

  validates :title, presence: true

  acts_as_tenant(:tenant)

  scope :active_assessments, -> { kept.where.not(status: :archived) }
end
