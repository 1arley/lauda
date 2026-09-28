class AnswerSet < ApplicationRecord
  belongs_to :instrument_application

  validates :answers, presence: true

  scope :ordered, -> { order(:position) }
end
