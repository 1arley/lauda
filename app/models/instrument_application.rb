class InstrumentApplication < ApplicationRecord
  include Auditable

  belongs_to :assessment
  belongs_to :instrument_version
  belongs_to :applied_by, class_name: 'User'
  has_many :answer_sets, dependent: :destroy
  has_many :score_results, dependent: :destroy

  enum :status, { pending: 0, answered: 1, scored: 2, error: 3 }

  delegate :instrument, to: :instrument_version

  def total_raw_score
    score_results.sum(:raw_score)
  end

  def compute!(normative_table_id:)
    Scoring::Engine.new(self).compute!(normative_table_id: normative_table_id)
  end
end
