class Instrument < ApplicationRecord
  has_many :instrument_versions, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  enum :category, {
    cognitive: 0,
    behavioral: 1,
    memory: 2,
    attention: 3,
    language: 4,
    neuropsychological: 5,
    personality: 6,
    other: 7
  }

  scope :active_instruments, -> { where(active: true) }
end
