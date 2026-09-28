class ScoreResult < ApplicationRecord
  belongs_to :instrument_application
  belongs_to :normative_table

  scope :ordered, -> { order(:position) }
end
