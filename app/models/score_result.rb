class ScoreResult < ApplicationRecord
  belongs_to :instrument_application
  belongs_to :normative_table

  scope :ordered, -> { order(:position) }

  def norm_changed?
    normative_fingerprint != Norms::Fingerprint.call(normative_table.data)
  end
end
