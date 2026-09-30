module Instruments
  # Importa instrumento, versão e tabela normativa a partir de um JSON de
  # material autorizado. A task `instruments:import` só delega para cá.
  class Import
    REQUIRED = %w[code name version norm_name scoring_config normative_table normative_data].freeze

    def self.call(path)
      new(path).call
    end

    def initialize(path)
      @path = File.expand_path(path)
      abort "Arquivo não encontrado: #{@path}" unless File.file?(@path)
    end

    def call
      payload = parsed
      source = payload['source'].presence ||
               abort('O JSON precisa do campo "source" com manual, edição e página.')
      missing = REQUIRED.reject { |field| payload[field].present? }
      abort "Campos obrigatórios ausentes no JSON: #{missing.join(', ')}" if missing.any?

      instrument = save_instrument(payload)
      version = save_version(instrument, payload, source)
      table = save_table(version, payload)

      report(instrument, version, table, source)
    rescue JSON::ParserError => e
      abort "JSON inválido: #{e.message}"
    end

    private

    def parsed
      JSON.parse(File.read(@path))
    end

    def save_instrument(payload)
      instrument = Instrument.find_or_initialize_by(code: payload['code'])
      instrument.assign_attributes(
        name: payload['name'],
        category: payload.fetch('category', 'cognitive'),
        author: payload['author'],
        publisher: payload['publisher'],
        description: payload['description']
      )
      instrument.save!
      instrument
    end

    def save_version(instrument, payload, source)
      version = instrument.instrument_versions.find_or_initialize_by(version: payload['version'])
      version.assign_attributes(
        norm_name: payload['norm_name'],
        norm_source: source,
        norm_year: payload['norm_year'],
        scoring_config: payload['scoring_config']
      )
      version.save!
      version
    end

    def save_table(version, payload)
      table = version.normative_tables.find_or_initialize_by(name: payload['normative_table'])
      table.assign_attributes(
        data: payload['normative_data'],
        age_range: payload['age_range'],
        education_level: payload['education_level']
      )
      table.save!
      table
    end

    def report(instrument, version, table, source)
      puts "Instrumento: #{instrument.code} (#{instrument.name})"
      puts "Versao:      #{version.display_name}"
      puts "Norma:       #{table.name} - #{table.data.fetch('scores', []).size} faixas"
      puts "Fonte:       #{source}"
    end
  end
end

namespace :instruments do
  desc 'Importa instrumento, versão e tabela normativa de um JSON autorizado (instruments:import[ARQUIVO])'
  task :import, [:arquivo] => :environment do |_task, args|
    if args[:arquivo].blank?
      abort 'Uso: bin/rails "instruments:import[caminho/do/instrumento.json]"'
    else
      Instruments::Import.call(args[:arquivo])
    end
  end
end
