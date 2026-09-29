module Scoring
  module Calculators
    class WiscIvCalculator < BaseCalculator
      def calculate
        results = []

        answer_sets.each do |answer_set|
          raw = answer_set.raw_total.to_f
          score = lookup_score(raw)

          results << {
            subtest_name: answer_set.subtest_name,
            raw_score: score[:raw_score],
            scaled_score: score[:scaled_score],
            percentile: score[:percentile],
            classification: score[:classification] || classify_percentile(score[:percentile]&.to_f),
            details: { answers: answer_set.answers }
          }
        end

        # Composite scores need their own conversion norms; summing scaled subtests
        # and applying index cutoffs would publish clinically invalid results.
        results
      end
    end
  end
end
