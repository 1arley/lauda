require 'rails_helper'

RSpec.describe 'Instrument answer validation', type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:assessment) do
    create(:assessment, tenant: tenant, owner: user, patient: create(:patient, tenant: tenant))
  end
  let(:instrument_version) do
    create(:instrument_version, scoring_config: {
             'subtests' => %w[Semelhanças Cubos], 'items_per_subtest' => 2
           })
  end
  let(:instrument_application) do
    create(:instrument_application, assessment: assessment, applied_by: user, instrument_version: instrument_version)
  end

  before { sign_in user }

  it 'keeps the user on the answer form if the submission has no answer sets', :aggregate_failures do
    patch update_answers_assessment_instrument_application_path(assessment, instrument_application), params: {}

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Informe pelo menos um escore para cada subteste antes de continuar.')
    expect(instrument_application.reload).to have_attributes(status: 'pending', applied_at: nil)
    expect(instrument_application.answer_sets).to be_empty
  end

  it 'rejects answer sets whose score fields are all blank', :aggregate_failures do
    patch update_answers_assessment_instrument_application_path(assessment, instrument_application), params: {
      answer_sets: { '0' => { subtest_name: 'Semelhanças', position: '0', answers: { '0' => '', '1' => '' } } }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Informe pelo menos um escore para cada subteste antes de continuar.')
    expect(instrument_application.reload).to have_attributes(status: 'pending', applied_at: nil)
    expect(instrument_application.answer_sets).to be_empty
  end

  it 'rejects a submission when only some subtests have scores', :aggregate_failures do
    patch update_answers_assessment_instrument_application_path(assessment, instrument_application), params: {
      answer_sets: {
        '0' => { subtest_name: 'Semelhanças', position: '0', answers: { '0' => '4' } },
        '1' => { subtest_name: 'Cubos', position: '1', answers: { '0' => '' } }
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Informe pelo menos um escore para cada subteste antes de continuar.')
    expect(instrument_application.reload).to have_attributes(status: 'pending', applied_at: nil)
    expect(instrument_application.answer_sets).to be_empty
  end
end
