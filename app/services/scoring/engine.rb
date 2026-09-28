module Scoring
  class Engine
    def initialize(instrument_application)
      @instrument_application = instrument_application
      @instrument = instrument_application.instrument_version.instrument
      @instrument_version = instrument_application.instrument_version
    end

    def compute!(normative_table_id:)
      normative_table = NormativeTable.find(normative_table_id)

      ActiveRecord::Base.transaction do
        @instrument_application.score_results.destroy_all

        calculator = find_calculator
        results = calculator.new(@instrument_application, normative_table).calculate

        results.each_with_index do |result, index|
          @instrument_application.score_results.create!(
            normative_table: normative_table,
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
      class_name = @instrument.code.camelize
      "Scoring::Calculators::#{class_name}Calculator".constantize
    rescue NameError
      Scoring::Calculators::GenericCalculator
    end
  end
end
