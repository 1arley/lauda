require 'rails_helper'

RSpec.describe Scoring::Calculators::GenericCalculator do
  subject(:results) { described_class.new(app, normative_table).calculate }

  let(:instrument_version) { create(:instrument_version) }
  let(:normative_table) { create(:normative_table, instrument_version: instrument_version) }
  let(:app) { create(:instrument_application, instrument_version: instrument_version) }
  let(:narrow_scores) do
    [{ min: 0, max: 5, scaled: 1, percentile: 0.1, classification: 'Muito baixo' }]
  end
  let(:unclassified_scores) { [{ min: 0, max: 999, scaled: 9, percentile: 50 }] }
  let(:answer_sets_attributes) do
    [
      { subtest_name: 'Cubos', position: 0, answers: { '1' => 4, '2' => 3, '3' => 2 } },
      { subtest_name: 'Reconhecimento', position: 1, answers: { '1' => 3, '2' => 2, '3' => 4 } }
    ]
  end

  before do
    answer_sets_attributes.each { |attributes| create(:answer_set, instrument_application: app, **attributes) }
  end

  it 'emits one result per answer set, in position order' do
    expect(results.pluck(:subtest_name)).to eq(%w[Cubos Reconhecimento])
  end

  it 'sums the raw answers of each subtest' do
    expect(results.pluck(:raw_score)).to eq([9.0, 9.0])
  end

  it 'carries the raw answers in details' do
    expect(results.first[:details]).to eq(answers: { '1' => 4, '2' => 3, '3' => 2 })
  end

  it 'normalises every subtest through the normative table' do
    expect(results.first).to include(scaled_score: 3, percentile: 2, classification: 'Limítrofe')
  end

  it 'does not add any aggregate result' do
    expect(results.size).to eq(2)
  end

  context 'when the answer set has no subtest name' do
    let(:answer_sets_attributes) do
      [{ subtest_name: nil, position: 0, answers: { '1' => 4, '2' => 3, '3' => 2 } }]
    end

    it 'labels the result as Total' do
      expect(results.pluck(:subtest_name)).to eq(['Total'])
    end
  end

  context 'when the raw score is outside every normative range' do
    let(:normative_table) do
      create(:normative_table, instrument_version: instrument_version, data: { scores: narrow_scores })
    end

    it 'flags the result as not normatised instead of inventing a scaled score' do
      expect(results.first).to include(
        raw_score: 9.0, scaled_score: nil, percentile: nil, classification: 'Não normatizado'
      )
    end
  end

  context 'when the normative row carries no classification' do
    let(:normative_table) do
      create(:normative_table, instrument_version: instrument_version, data: { scores: unclassified_scores })
    end

    it 'falls back to classifying by percentile' do
      expect(results.first[:classification]).to eq('Médio')
    end
  end
end
