require 'json'

module Scoring
  class ConformityCheck
    def initialize(instrument_code:, version:, fixture_path:)
      @instrument = Instrument.find_by!(code: instrument_code)
      @version = @instrument.instrument_versions.find_by!(version: version)
      @fixture = JSON.parse(File.read(fixture_path))
      @fixture.fetch('source')
      @normative_table = @version.normative_tables.find_by!(name: @fixture.fetch('normative_table'))
    end

    def results
      application = build_application
      calculator_class.new(application, @normative_table).calculate.map do |result|
        expected = @fixture.fetch('expected').find { |row| row.fetch('subtest_name') == result[:subtest_name] }
        {
          subtest_name: result[:subtest_name],
          raw_score: result[:raw_score],
          expected_raw_score: expected&.[]('raw_score'),
          scaled_score: result[:scaled_score],
          expected_scaled_score: expected&.[]('scaled_score')
        }
      end
    end

    def passed?
      expected_names = @fixture.fetch('expected').map { |row| row.fetch('subtest_name') }
      actual = results
      actual.map { |row| row[:subtest_name] } == expected_names && actual.all? do |row|
        numeric_match?(row[:raw_score], row[:expected_raw_score]) &&
          numeric_match?(row[:scaled_score], row[:expected_scaled_score])
      end
    end

    private

    def build_application
      patient = Patient.new(birth_date: birth_date)
      assessment = Assessment.new(patient: patient)
      application = InstrumentApplication.new(instrument_version: @version, assessment: assessment)
      @fixture.fetch('answer_sets').each do |answer_set|
        application.answer_sets.build(
          subtest_name: answer_set.fetch('subtest_name'),
          position: answer_set.fetch('position'),
          answers: answer_set.fetch('answers')
        )
      end
      application
    end

    def birth_date
      return Date.parse(@fixture['patient_birth_date']) if @fixture['patient_birth_date']
      return unless @fixture['patient_age']

      Date.current - @fixture['patient_age'].to_i.years
    end

    def calculator_class
      class_name = @instrument.code.downcase.tr('-', '_').camelize
      "Scoring::Calculators::#{class_name}Calculator".constantize
    rescue NameError
      Scoring::Calculators::GenericCalculator
    end

    def numeric_match?(actual, expected)
      return expected.nil? if actual.nil?

      expected.present? && actual.to_d == expected.to_d
    end
  end
end
