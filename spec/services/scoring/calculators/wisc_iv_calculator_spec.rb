require 'rails_helper'

RSpec.describe Scoring::Calculators::WiscIvCalculator do
  subject(:calculator) { described_class.new(app, normative_table) }

  let(:instrument_version) { create(:instrument_version) }
  let(:normative_table) { create(:normative_table, instrument_version: instrument_version) }
  let(:app) { create(:instrument_application, instrument_version: instrument_version) }
  let(:only_first_subtests) do
    [
      { subtest_name: 'Semelhanças', position: 0, answers: { '1' => 3, '2' => 2, '3' => 4 } },
      { subtest_name: 'Cubos', position: 1, answers: { '1' => 4, '2' => 3, '3' => 2 } }
    ]
  end
  # Semelhanças raw 9, Vocabulário raw 30, Compreensão raw 39, Cubos raw 9, Dígitos raw 27.
  let(:full_protocol) do
    [
      { subtest_name: 'Semelhanças', position: 0, answers: { '1' => 3, '2' => 2, '3' => 4 } },
      { subtest_name: 'Vocabulário', position: 1, answers: { '1' => 10, '2' => 10, '3' => 10 } },
      { subtest_name: 'Compreensão', position: 2, answers: { '1' => 13, '2' => 13, '3' => 13 } },
      { subtest_name: 'Cubos', position: 3, answers: { '1' => 4, '2' => 3, '3' => 2 } },
      { subtest_name: 'Dígitos', position: 4, answers: { '1' => 9, '2' => 9, '3' => 9 } }
    ]
  end
  let(:answer_sets_attributes) { full_protocol }
  let(:expected_names) do
    %w[Semelhanças Vocabulário Compreensão Cubos Dígitos]
  end

  before do
    answer_sets_attributes.each { |attributes| create(:answer_set, instrument_application: app, **attributes) }
  end

  describe '#calculate' do
    it 'emits one result per answer set' do
      expect(calculator.calculate.pluck(:subtest_name)).to eq(expected_names)
    end

    it 'normalises each subtest independently' do
      verbal = calculator.calculate.find { |result| result[:subtest_name] == 'Semelhanças' }

      expect(verbal).to include(raw_score: 9.0, scaled_score: 3, percentile: 2, classification: 'Limítrofe')
    end

    it 'does not emit composites without composite conversion norms' do
      expect(calculator.calculate.pluck(:subtest_name)).not_to include('Compreensão Verbal')
    end

    context 'when only part of a composite was answered' do
      let(:answer_sets_attributes) { only_first_subtests }

      it 'does not emit a partial composite' do
        expect(calculator.calculate.pluck(:subtest_name)).not_to include('Compreensão Verbal')
      end
    end

    context 'when a subtest has no normative row' do
      # Só Semelhanças (raw 9) cabe na tabela; Vocabulário e Compreensão ficam de fora.
      let(:normative_table) do
        scores = [{ min: 0, max: 9, scaled: 3, percentile: 2, classification: 'Limítrofe' }]
        create(:normative_table, instrument_version: instrument_version, data: { scores: scores })
      end

      it 'keeps the unnormed subtest result out of composite output' do
        expect(calculator.calculate.pluck(:subtest_name)).not_to include('Compreensão Verbal')
      end
    end

    context 'when no subtest of a composite has a normative row' do
      let(:normative_table) do
        scores = [{ min: 0, max: 5, scaled: 1, percentile: 0.1, classification: 'Muito baixo' }]
        create(:normative_table, instrument_version: instrument_version, data: { scores: scores })
      end

      it 'omits the composite instead of publishing a zero score' do
        expect(calculator.calculate.pluck(:subtest_name)).not_to include('Compreensão Verbal')
      end
    end
  end
end
