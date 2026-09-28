module Scoring
  module Calculators
    class Srs2Calculator < BaseCalculator
      DOMAINS = {
        'Consciência Social' => (1..10),
        'Cognição Social' => (11..20),
        'Comunicação Social' => (21..30),
        'Maneirismos' => (31..40),
        'Interesses Restritos e Comportamentos Repetitivos' => (41..50)
      }.freeze

      def calculate
        results = []
        all_answers = answer_sets.flat_map(&:answers)

        DOMAINS.each do |domain_name, item_range|
          domain_answers = item_range.filter_map { |i| all_answers[i.to_s]&.to_i }
          raw = domain_answers.sum

          score = lookup_score(raw)
          results << {
            subtest_name: domain_name,
            raw_score: score[:raw_score],
            scaled_score: score[:scaled_score],
            percentile: score[:percentile],
            classification: score[:classification] || classify_percentile(score[:percentile]&.to_f),
            details: { item_count: domain_answers.size, items: item_range.to_a }
          }
        end

        total_raw = results.sum { |r| r[:raw_score]&.to_f || 0 }
        results << {
          subtest_name: 'Escore Total SRS-2',
          raw_score: total_raw,
          scaled_score: nil,
          percentile: nil,
          classification: classify_total(total_raw),
          details: { domains: results.pluck(:subtest_name) }
        }

        results
      end

      private

      def classify_total(score)
        case score
        when 0..25 then 'Dentro dos limites normativos'
        when 26..40 then 'Leve dificuldade'
        when 41..60 then 'Moderada dificuldade'
        when 61..80 then 'Moderadamente severa'
        else 'Severa dificuldade'
        end
      end
    end
  end
end
