module Scoring
  module Calculators
    class WiscIvCalculator < BaseCalculator
      COMPOSITES = {
        'Compreensão Verbal' => %w[Semelhanças Vocabulário Compreensão],
        'Organização Perceptual' => %w[Cubos Conceitos Figuras Completas Raciocínio Matricial],
        'Memória Operacional' => %w[Dígitos Sequência de Números e Letras],
        'Velocidade de Processamento' => %w[Código Símbolos]
      }.freeze

      def calculate
        results = []

        subtest_scores = {}
        answer_sets.each do |answer_set|
          raw = answer_set.answers.values.sum.to_f
          score = lookup_score(raw)
          subtest_scores[answer_set.subtest_name] = score

          results << {
            subtest_name: answer_set.subtest_name,
            raw_score: score[:raw_score],
            scaled_score: score[:scaled_score],
            percentile: score[:percentile],
            classification: score[:classification] || classify_percentile(score[:percentile]&.to_f),
            details: { answers: answer_set.answers }
          }
        end

        COMPOSITES.each do |composite_name, subtests|
          subtest_scales = subtests.filter_map { |s| subtest_scores[s]&.dig(:scaled_score)&.to_f }
          next if subtest_scales.empty?

          composite_score = subtest_scales.sum
          results << {
            subtest_name: composite_name,
            raw_score: composite_score,
            scaled_score: composite_score,
            percentile: nil,
            classification: classify_composite(composite_score),
            details: { subtests: subtests, subtest_scores: subtest_scales }
          }
        end

        results
      end

      private

      def classify_composite(score)
        case score
        when 130..Float::INFINITY then 'Muito Superior'
        when 120...130 then 'Superior'
        when 110...120 then 'Médio Superior'
        when 90...110 then 'Médio'
        when 80...90 then 'Médio Inferior'
        when 70...80 then 'Limítrofe'
        when -Float::INFINITY...70 then 'Muito Baixo'
        end
      end
    end
  end
end
