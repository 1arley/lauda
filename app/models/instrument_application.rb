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

  def update_answers!(attributes_by_index)
    self.class.transaction do
      attributes_by_index.each_value do |attributes|
        answer_set = answer_sets.find_or_initialize_by(subtest_name: attributes[:subtest_name])
        answer_set.assign_attributes(answers: attributes[:answers], position: attributes[:position])
        answer_set.save!
      end

      update!(status: :answered, applied_at: Time.current)
    end
  end

  def compute!(normative_table_id:)
    normative_table = instrument_version.normative_tables.find(normative_table_id)
    Scoring::Engine.new(self, normative_table).compute!
  end
end
