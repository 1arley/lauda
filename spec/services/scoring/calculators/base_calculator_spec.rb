require 'rails_helper'

RSpec.describe Scoring::Calculators::BaseCalculator do
  subject(:calculator) { concrete_class.new(app, normative_table) }

  let(:concrete_class) { Class.new(described_class) }
  let(:instrument_version) { create(:instrument_version) }
  let(:normative_table) { create(:normative_table, instrument_version: instrument_version) }
  let(:app) { create(:instrument_application, instrument_version: instrument_version) }
  let(:scores) { [{ min: 0, max: 5, scaled: 1, percentile: 0.1, classification: 'Muito baixo' }] }
  let(:age_banded_scores) do
    [
      { min: 0, max: 999, scaled: 7, percentile: 23, classification: 'Médio', age_min: 6, age_max: 11 },
      { min: 0, max: 999, scaled: 12, percentile: 86, classification: 'Médio Superior', age_min: 12, age_max: 16 }
    ]
  end
  let(:scorer) { concrete_class.new(app, table) }
  let(:table) { normative_table }

  describe '#calculate' do
    it 'forces subclasses to provide their own calculation' do
      expect { calculator.calculate }.to raise_error(NotImplementedError, /must implement #calculate/)
    end
  end

  describe '#answer_sets' do
    before do
      create(:answer_set, instrument_application: app, subtest_name: 'Cubos', position: 1, answers: { '1' => 1 })
      create(:answer_set, instrument_application: app, subtest_name: 'Semelhanças', position: 0, answers: { '1' => 1 })
    end

    it 'exposes the answer sets in position order' do
      expect(calculator.answer_sets.map(&:subtest_name)).to eq(%w[Semelhanças Cubos])
    end
  end

  describe '#lookup_score' do
    it 'returns the normative row matching the raw score' do
      expect(calculator.send(:lookup_score, 9)).to eq(
        raw_score: 9, scaled_score: 3, percentile: 2, classification: 'Limítrofe'
      )
    end

    context 'when the raw score falls outside every range' do
      let(:table) { create(:normative_table, instrument_version: instrument_version, data: { scores: scores }) }

      it 'returns the default result rather than a fabricated norm' do
        expect(scorer.send(:lookup_score, 9)).to eq(
          raw_score: 9, scaled_score: nil, percentile: nil, classification: 'Não normatizado'
        )
      end
    end

    context 'when the table defines age bands' do
      let(:table) do
        create(:normative_table, instrument_version: instrument_version, data: { scores: age_banded_scores })
      end

      it 'picks the band matching the patient age', :aggregate_failures do
        expect(scorer.send(:lookup_score, 9, age: 9)[:scaled_score]).to eq(7)
        expect(scorer.send(:lookup_score, 9, age: 14)[:scaled_score]).to eq(12)
      end

      it 'returns an unnormed result when the table requires age and no age is given' do
        expect(scorer.send(:lookup_score, 9)).to include(scaled_score: nil, classification: 'Não normatizado')
      end

      it 'uses the patient age from the associated assessment' do
        patient = create(:patient, birth_date: 9.years.ago.to_date)
        assessment = create(:assessment, patient: patient)
        app.update!(assessment: assessment)

        expect(scorer.send(:lookup_score, 9)[:scaled_score]).to eq(7)
      end
    end
  end

  describe '#classify_percentile' do
    {
      99.9 => 'Muito alto',
      95.0 => 'Muito alto',
      94.9 => 'Alto',
      85.0 => 'Alto',
      84.9 => 'Médio',
      50.0 => 'Médio',
      16.0 => 'Médio',
      15.9 => 'Baixo',
      5.0 => 'Baixo',
      4.9 => 'Muito baixo',
      0.0 => 'Muito baixo'
    }.each do |percentile, expected|
      it "labels #{percentile} as #{expected}" do
        expect(calculator.send(:classify_percentile, percentile)).to eq(expected)
      end
    end

    it 'returns nil-safe fallback when the percentile is unknown' do
      expect(calculator.send(:classify_percentile, nil)).to eq('Não classificado')
    end
  end
end
