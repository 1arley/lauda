module Scoring
  module Calculators
    class BaseCalculator
      attr_reader :instrument_application, :normative_table, :answer_sets

      def initialize(instrument_application, normative_table)
        @instrument_application = instrument_application
        @normative_table = normative_table
        @answer_sets = instrument_application.answer_sets.ordered
      end

      def calculate
        raise NotImplementedError, "#{self.class} must implement #calculate"
      end

      private

      def total_raw_score
        answer_sets.sum { |as| as.answers.values.sum.to_f }
      end

      def lookup_score(raw_score, age: nil, education_level: nil)
        result = normative_table.lookup(
          raw_score: raw_score,
          age: age,
          education_level: education_level
        )

        return default_result(raw_score) unless result

        {
          raw_score: raw_score,
          scaled_score: result['scaled'],
          percentile: result['percentile'],
          classification: result['classification']
        }
      end

      def default_result(raw_score)
        {
          raw_score: raw_score,
          scaled_score: nil,
          percentile: nil,
          classification: 'Não normatizado'
        }
      end

      def classify_percentile(percentile)
        case percentile
        when 95..Float::INFINITY then 'Muito alto'
        when 85...95 then 'Alto'
        when 16...85 then 'Médio'
        when 5...16 then 'Baixo'
        when -Float::INFINITY...5 then 'Muito baixo'
        else 'Não classificado'
        end
      end
    end
  end
end
