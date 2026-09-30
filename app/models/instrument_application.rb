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

  def norm_changed?
    score_results.includes(:normative_table).any?(&:norm_changed?)
  end

  def update_answers!(attributes_by_index)
    unless answers_present?(attributes_by_index)
      errors.add(:base, 'Informe pelo menos um escore para cada subteste antes de continuar.')
      raise ActiveRecord::RecordInvalid.new(self)
    end

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

  private

  def answers_present?(attributes_by_index)
    return false unless attributes_by_index.respond_to?(:values)

    submitted = attributes_by_index.values.each_with_object({}) do |attributes, answers_by_subtest|
      next unless attributes.respond_to?(:[])

      subtest_name = attributes[:subtest_name] || attributes['subtest_name']
      answers = attributes[:answers] || attributes['answers']
      answers_by_subtest[subtest_name] = answers if subtest_name.present?
    end

    expected_subtests = instrument_version.scoring_config['subtests']
    expected_subtests.present? && expected_subtests.all? do |subtest_name|
      answers = submitted[subtest_name]
      answers.respond_to?(:values) && answers.values.any?(&:present?)
    end
  end
end
