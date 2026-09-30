module Scoring
  class Engine
    def initialize(instrument_application, normative_table)
      @instrument_application = instrument_application
      @instrument = instrument_application.instrument_version.instrument
      @normative_table = normative_table
    end

    def compute!
      ActiveRecord::Base.transaction do
        @instrument_application.score_results.destroy_all

        calculator = find_calculator
        results = calculator.new(@instrument_application, @normative_table).calculate

        results.each_with_index do |result, index|
          @instrument_application.score_results.create!(
            normative_table: @normative_table,
            normative_fingerprint: Norms::Fingerprint.call(@normative_table.data),
            subtest_name: result[:subtest_name],
            position: index,
            raw_score: result[:raw_score],
            scaled_score: result[:scaled_score],
            percentile: result[:percentile],
            classification: result[:classification],
            details: result[:details] || {},
            computed_at: Time.current
          )
        end

        @instrument_application.update!(
          status: :scored,
          scored_at: Time.current
        )
      end
    end

    private

    def find_calculator
      # 'WISC-IV'.camelize devolve 'WISC-IV' (nada é transformado), então normaliza para
      # minúsculas com '_' e casa com WiscIvCalculator / Srs2Calculator. Sem match → Generic.
      class_name = @instrument.code.downcase.tr('-', '_').camelize
      "Scoring::Calculators::#{class_name}Calculator".constantize
    rescue NameError
      Scoring::Calculators::GenericCalculator
    end
  end
end
