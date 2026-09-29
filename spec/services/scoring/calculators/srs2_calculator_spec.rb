require 'rails_helper'

RSpec.describe Scoring::Calculators::Srs2Calculator do
  subject(:results) { described_class.new(app, normative_table).calculate }

  let(:instrument_version) { create(:instrument_version) }
  let(:normative_table) { create(:normative_table, instrument_version: instrument_version) }
  let(:app) { create(:instrument_application, instrument_version: instrument_version) }
  # Itens 1-10 valem 1, 11-20 valem 2, ... 41-50 valem 5: cada domínio soma 10, 20, 30, 40 e 50.
  let(:answers) { (1..50).index_with { |item| ((item - 1) / 10) + 1 } }
  let(:answer_sets_attributes) { [{ subtest_name: 'Itens', position: 0, answers: answers }] }
  let(:domain_names) { described_class::DOMAINS.keys }
  let(:expected_names) { domain_names + ['Escore Total SRS-2'] }
  let(:domain_results) { results.first(5) }
  let(:total) { results.last }

  before do
    answer_sets_attributes.each { |attributes| create(:answer_set, instrument_application: app, **attributes) }
  end

  describe '#calculate' do
    it 'emits the five domains followed by the total' do
      expect(results.pluck(:subtest_name)).to eq(expected_names)
    end

    it 'sums only the answers inside each domain item range' do
      expect(domain_results.pluck(:raw_score)).to eq([10, 20, 30, 40, 50])
    end

    it 'normalises each domain through the normative table' do
      expect(results.first).to include(scaled_score: 3, percentile: 2, classification: 'Limítrofe')
    end

    it 'records the answered item count and the item range in details' do
      expect(results.first[:details]).to eq(item_count: 10, items: (1..10).to_a)
    end

    it 'appends the total as the sum of the domain raw scores' do
      expect(total).to include(subtest_name: 'Escore Total SRS-2', raw_score: 150, scaled_score: nil)
    end

    it 'lists the domains in the total details' do
      expect(total[:details][:domains]).to eq(domain_names)
    end

    describe '#classify_total' do
      {
        0 => 'Dentro dos limites normativos',
        25 => 'Dentro dos limites normativos',
        26 => 'Leve dificuldade',
        40 => 'Leve dificuldade',
        41 => 'Moderada dificuldade',
        60 => 'Moderada dificuldade',
        61 => 'Moderadamente severa',
        80 => 'Moderadamente severa',
        81 => 'Severa dificuldade'
      }.each do |score, expected|
        it "labels #{score} as #{expected}" do
          expect(described_class.new(app, normative_table).send(:classify_total, score)).to eq(expected)
        end
      end
    end
  end

  context 'when the items are spread across several answer sets' do
    let(:answer_sets_attributes) do
      first_half, second_half = answers.partition { |item, _value| item <= 25 }
      [
        { subtest_name: 'Parte 1', position: 0, answers: first_half.to_h },
        { subtest_name: 'Parte 2', position: 1, answers: second_half.to_h }
      ]
    end

    it 'merges the answers before splitting them into domains' do
      expect(domain_results.pluck(:raw_score)).to eq([10, 20, 30, 40, 50])
    end
  end

  context 'when some items were never answered' do
    let(:answer_sets_attributes) do
      [{ subtest_name: 'Itens', position: 0, answers: answers.except(6, 7, 8, 9, 10) }]
    end

    it 'counts only the answered items of the domain', :aggregate_failures do
      expect(results.first).to include(raw_score: 5)
      expect(results.first[:details][:item_count]).to eq(5)
    end
  end
end
