class AnswerSet < ApplicationRecord
  belongs_to :instrument_application

  validates :answers, presence: true

  scope :ordered, -> { order(:position) }

  # As respostas chegam do formulário como string; o cálculo precisa de número.
  def answer_for(index)
    answers[index.to_s].to_i
  end

  def raw_total
    answers.each_value.sum(&:to_i)
  end
end
