FactoryBot.define do
  factory :instrument do
    code { 'WISC-IV' }
    name { 'Escala Wechsler de Inteligência para Crianças - 4ª Edição' }
    category { :cognitive }
  end

  factory :instrument_version do
    association :instrument
    version { '1.0' }
    norm_name { 'Padrão brasileiro' }
    norm_year { 2013 }
  end

  factory :normative_table do
    association :instrument_version
    name { 'Faixa etária 6-16 anos' }
    data do
      {
        scores: [
          { min: 0, max: 5, scaled: 1, percentile: 0.1, classification: 'Muito baixo' },
          { min: 6, max: 8, scaled: 2, percentile: 0.5, classification: 'Muito baixo' },
          { min: 9, max: 11, scaled: 3, percentile: 2, classification: 'Limítrofe' },
          { min: 12, max: 14, scaled: 4, percentile: 5, classification: 'Limítrofe' },
          { min: 15, max: 17, scaled: 5, percentile: 9, classification: 'Médio Inferior' },
          { min: 18, max: 20, scaled: 6, percentile: 14, classification: 'Médio Inferior' },
          { min: 21, max: 23, scaled: 7, percentile: 23, classification: 'Médio' },
          { min: 24, max: 26, scaled: 8, percentile: 37, classification: 'Médio' },
          { min: 27, max: 29, scaled: 9, percentile: 50, classification: 'Médio' },
          { min: 30, max: 32, scaled: 10, percentile: 63, classification: 'Médio' },
          { min: 33, max: 35, scaled: 11, percentile: 77, classification: 'Médio Superior' },
          { min: 36, max: 38, scaled: 12, percentile: 86, classification: 'Médio Superior' },
          { min: 39, max: 41, scaled: 13, percentile: 91, classification: 'Superior' },
          { min: 42, max: 44, scaled: 14, percentile: 95, classification: 'Muito Superior' },
          { min: 45, max: 999, scaled: 15, percentile: 99, classification: 'Muito Superior' }
        ]
      }
    end
  end
end
