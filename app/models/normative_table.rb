class NormativeTable < ApplicationRecord
  belongs_to :instrument_version
  has_many :score_results, dependent: :nullify

  validates :name, presence: true
  validates :data, presence: true

  def lookup(raw_score:, age: nil, education_level: nil)
    table_data = data['scores'] || data
    table_data.find { |row| score_matches?(row, raw_score, age, education_level) }
  end

  private

  def score_matches?(row, raw_score, age, education_level)
    score_in_range?(row, raw_score) && age_matches?(row, age) && education_matches?(row, education_level)
  end

  def score_in_range?(row, raw_score)
    raw_score.between?(row['min'].to_i, row['max'].to_i)
  end

  def age_matches?(row, age)
    return true if row['age_min'].nil? && row['age_max'].nil?
    return false if age.blank?

    age.between?(row['age_min'].to_i, row['age_max'].to_i)
  end

  def education_matches?(row, education_level)
    education_level.nil? || row['education'].nil? || row['education'] == education_level
  end
end
