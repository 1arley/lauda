class InstrumentVersion < ApplicationRecord
  belongs_to :instrument
  has_many :normative_tables, dependent: :destroy
  has_many :instrument_applications, dependent: :destroy

  validates :version, presence: true, uniqueness: { scope: :instrument_id }
  validates :norm_name, presence: true

  scope :active_versions, -> { where(active: true) }

  def display_name
    "#{instrument.name} v#{version} (#{norm_name})"
  end
end
