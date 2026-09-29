require 'rails_helper'

RSpec.describe Scoring::Engine do
  subject(:engine) { described_class.new(app, normative_table) }

  let(:instrument) { create(:instrument, code: 'WISC-IV') }
  let(:instrument_version) { create(:instrument_version, instrument: instrument) }
  let(:normative_table) { create(:normative_table, instrument_version: instrument_version) }
  let(:app) { create(:instrument_application, instrument_version: instrument_version) }
  let(:answer_sets_attributes) do
    [
      { subtest_name: 'Semelhanças', position: 0, answers: { '1' => 3, '2' => 2, '3' => 4 } },
      { subtest_name: 'Cubos', position: 1, answers: { '1' => 4, '2' => 3, '3' => 2 } }
    ]
  end

  before do
    answer_sets_attributes.each do |attributes|
      create(:answer_set, instrument_application: app, **attributes)
    end
  end

  describe '#compute!' do
    it 'persists one score result per calculator result' do
      expect { engine.compute! }.to change(ScoreResult, :count).by(2)
    end

    it 'marks the application as scored' do
      engine.compute!
      expect(app.reload.status).to eq('scored')
    end

    it 'stamps scored_at' do
      engine.compute!
      expect(app.reload.scored_at).to be_present
    end

    it 'links every result to the given normative table' do
      engine.compute!
      expect(app.score_results.distinct.pluck(:normative_table_id)).to eq([normative_table.id])
    end

    it 'numbers results sequentially following the calculator order' do
      engine.compute!
      expect(app.score_results.ordered.pluck(:position)).to eq([0, 1])
    end

    it 'stamps computed_at on every result' do
      engine.compute!
      expect(app.score_results.pluck(:computed_at)).to all(be_present)
    end

    it 'replaces previously computed results instead of appending' do
      engine.compute!
      expect { engine.compute! }.not_to change(ScoreResult, :count)
    end

    context 'when the calculator raises' do
      let(:broken_calculator) do
        instance_double(Scoring::Calculators::BaseCalculator, calculate: nil).tap do |double|
          allow(double).to receive(:calculate).and_raise(TypeError, 'falha no cálculo')
        end
      end

      before { allow(Scoring::Calculators::WiscIvCalculator).to receive(:new).and_return(broken_calculator) }

      it 'rolls back the transaction, leaving the application untouched', :aggregate_failures do
        expect { engine.compute! }.to raise_error(TypeError)
        expect(ScoreResult.count).to eq(0)
        expect(app.reload.status).to eq('pending')
      end
    end
  end

  describe 'calculator resolution' do
    context 'with WISC-IV' do
      it 'uses the dedicated calculator and omits composites without conversion norms' do
        engine.compute!
        expect(app.score_results.pluck(:subtest_name))
          .to contain_exactly('Semelhanças', 'Cubos')
      end
    end

    context 'with SRS-2' do
      let(:instrument) { create(:instrument, code: 'SRS-2') }
      let(:answer_sets_attributes) do
        [{ subtest_name: 'Itens', position: 0, answers: (1..50).index_with(1) }]
      end

      it 'uses the SRS-2 calculator, adding the five domains plus the total' do
        engine.compute!
        expect(app.score_results.pluck(:subtest_name)).to include(
          'Consciência Social', 'Cognição Social', 'Comunicação Social', 'Maneirismos',
          'Interesses Restritos e Comportamentos Repetitivos', 'Escore Total SRS-2'
        )
      end
    end

    context 'with an instrument without a dedicated calculator' do
      let(:instrument) { create(:instrument, code: 'INSTRUMENTO-SEM-CALCULADORA') }

      it 'falls back to the generic calculator, one result per answer set' do
        engine.compute!
        expect(app.score_results.pluck(:subtest_name)).to contain_exactly('Semelhanças', 'Cubos')
      end
    end
  end
end
