require 'rails_helper'

RSpec.describe InstrumentApplication do
  describe '#update_answers!' do
    let(:app) do
      version = create(:instrument_version, scoring_config: {
        'subtests' => %w[Semelhanças Cubos], 'items_per_subtest' => 2
      })
      create(:instrument_application, instrument_version: version)
    end
    let(:answers) do
      {
        '0' => { subtest_name: 'Semelhanças', position: 0, answers: { '1' => 3 } },
        '1' => { subtest_name: 'Cubos', position: 1, answers: { '1' => 4 } }
      }
    end
    let(:stored_answers) { app.answer_sets.ordered.pluck(:subtest_name, :answers) }

    it 'persists one answer set per subtest' do
      app.update_answers!(answers)

      expect(stored_answers).to eq([['Semelhanças', { '1' => 3 }], ['Cubos', { '1' => 4 }]])
    end

    it 'marks the application answered and stamps applied_at', :aggregate_failures do
      app.update_answers!(answers)

      expect(app.reload).to have_attributes(status: 'answered')
      expect(app.applied_at).to be_present
    end

    it 'overwrites the answers of a subtest that already exists' do
      app.update_answers!(answers)
      answers['0'][:answers] = { '1' => 5 }
      app.update_answers!(answers)

      expect(stored_answers).to eq([['Semelhanças', { '1' => 5 }], ['Cubos', { '1' => 4 }]])
    end

    it 'rolls back all answer changes when one answer set is invalid', :aggregate_failures do
      answers['1'][:answers] = {}

      expect { app.update_answers!(answers) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(app.reload).to have_attributes(status: 'pending')
      expect(app.answer_sets).to be_empty
    end

    it 'rejects blank or missing scores for any subtest' do
      answers['0'][:answers] = { '1' => 3 }
      answers['1'][:answers] = { '1' => '' }

      expect { app.update_answers!(answers) }.to raise_error(ActiveRecord::RecordInvalid, /escore para cada subteste/)
      expect(app.reload).to have_attributes(status: 'pending')
      expect(app.answer_sets).to be_empty
    end
  end
end
