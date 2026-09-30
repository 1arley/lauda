class NormativeTable < ApplicationRecord
  belongs_to :instrument_version
  has_many :score_results, dependent: :nullify

  validates :name, presence: true
  validates :data, presence: true

  def lookup(raw_score:, age: nil, education_level: nil)
    table_data = data['scores'] || data
    table_data.find do |row|
      matches_range = raw_score.between?(row['min'].to_i, row['max'].to_i)
      age_range_missing = row['age_min'].nil? && row['age_max'].nil?
      age_match = age_range_missing || (age.present? && age.between?(row['age_min'].to_i, row['age_max'].to_i))
      education_match = education_level.nil? || row['education'].nil? || row['education'] == education_level
      matches_range && age_match && education_match
    end
  end
end
