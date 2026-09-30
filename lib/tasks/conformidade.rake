module Conformidade
  def self.print_result(row)
    raw_matches = if row[:raw_score].nil?
                    row[:expected_raw_score].nil?
                  else
                    row[:raw_score].to_d == row[:expected_raw_score].to_d
                  end
    scaled_matches = if row[:scaled_score].nil?
                       row[:expected_scaled_score].nil?
                     else
                       row[:scaled_score].to_d == row[:expected_scaled_score].to_d
                     end
    marker = raw_matches && scaled_matches ? 'OK' : 'DIVERGÊNCIA'
    puts [marker, row[:subtest_name], row[:raw_score], row[:expected_raw_score], row[:scaled_score],
          row[:expected_scaled_score]].join(' | ')
  end
end

namespace :conformidade do
  desc 'Confere escores do calculador contra um exemplo publicado em JSON'
  task :conferir, %i[instrumento versao arquivo] => :environment do |_task, args|
    unless args[:instrumento] && args[:versao]
      abort 'Uso: bin/rails "conformidade:conferir[CODIGO,VERSAO[,ARQUIVO_JSON]]"'
    end

    fixture_path = args[:arquivo] || Rails.root.join(
      'spec/fixtures/conformidade',
      "#{args[:instrumento].downcase.tr('-', '_')}_#{args[:versao]}.json"
    )
    abort "Exemplo JSON não encontrado: #{fixture_path}" unless File.file?(fixture_path)

    check = Scoring::ConformityCheck.new(
      instrument_code: args[:instrumento],
      version: args[:versao],
      fixture_path: fixture_path
    )
    puts 'Subteste | Bruto obtido | Bruto publicado | Padronizado obtido | Padronizado publicado'
    check.results.each { |row| Conformidade.print_result(row) }
    abort 'Exemplo de conformidade divergiu.' unless check.passed?
  rescue JSON::ParserError => e
    abort "JSON inválido: #{e.message}"
  end
end
