namespace :conformidade do
  desc 'Confere escores do calculador contra um exemplo publicado em JSON'
  task :conferir, %i[instrumento versao arquivo] => :environment do |_task, args|
    abort 'Uso: bin/rails "conformidade:conferir[CODIGO,VERSAO[,ARQUIVO_JSON]]"' unless args[:instrumento] && args[:versao]

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
    puts "Subteste | Bruto obtido | Bruto publicado | Padronizado obtido | Padronizado publicado"
    check.results.each do |row|
      raw_matches = row[:raw_score].nil? ? row[:expected_raw_score].nil? : row[:raw_score].to_d == row[:expected_raw_score].to_d
      scaled_matches = row[:scaled_score].nil? ? row[:expected_scaled_score].nil? : row[:scaled_score].to_d == row[:expected_scaled_score].to_d
      matches = raw_matches && scaled_matches
      marker = matches ? 'OK' : 'DIVERGÊNCIA'
      puts "#{marker} | #{row[:subtest_name]} | #{row[:raw_score]} | #{row[:expected_raw_score]} | #{row[:scaled_score]} | #{row[:expected_scaled_score]}"
    end
    abort 'Exemplo de conformidade divergiu.' unless check.passed?
  rescue JSON::ParserError => e
    abort "JSON inválido: #{e.message}"
  end
end
