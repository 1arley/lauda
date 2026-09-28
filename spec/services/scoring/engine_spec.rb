require 'rails_helper'

RSpec.describe Scoring::Engine do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :professional, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:instrument) { create(:instrument, code: 'WISC-IV') }
  let(:instrument_version) { create(:instrument_version, instrument: instrument) }
  let(:normative_table) { create(:normative_table, instrument_version: instrument_version) }
  let(:assessment) { create(:assessment, tenant: tenant, patient: patient, owner: user) }
  let(:app) do
    create(:instrument_application, assessment: assessment, instrument_version: instrument_version, applied_by: user)
  end

  before do
    ActsAsTenant.tenant_id = tenant.id
    create(:answer_set, instrument_application: app, subtest_name: 'Semelhanças',
                        answers: { '1' => 3, '2' => 2, '3' => 4 })
    create(:answer_set, instrument_application: app, subtest_name: 'Cubos', answers: { '1' => 4, '2' => 3, '3' => 2 })
  end

  describe '#compute!' do
    it 'creates score results each answer set' do
      expect do
        described_class.new(app).compute!(normative_table_id: normative_table.id)
      end.to change(ScoreResult, :count).by(2)
    end

    it 'updates instrument application status to scored' do
      described_class.new(app).compute!(normative_table_id: normative_table.id)
      expect(app.reload.status).to eq('scored')
    end

    it 'sets computed_at timestamp' do
      described_class.new(app).compute!(normative_table_id: normative_table.id)
      expect(app.reload.scored_at).to be_present
    end
  end
end
