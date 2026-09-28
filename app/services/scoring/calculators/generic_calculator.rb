module Scoring
  module Calculators
    class GenericCalculator < BaseCalculator
      def calculate
        answer_sets.map do |answer_set|
          raw = answer_set.answers.values.sum.to_f
          score = lookup_score(raw)

          {
            subtest_name: answer_set.subtest_name || 'Total',
            raw_score: score[:raw_score],
            scaled_score: score[:scaled_score],
            percentile: score[:percentile],
            classification: score[:classification] || classify_percentile(score[:percentile]&.to_f),
            details: { answers: answer_set.answers }
          }
        end
      end
    end
  end
end
