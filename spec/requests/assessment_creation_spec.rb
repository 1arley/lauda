require 'rails_helper'

RSpec.describe 'Assessment creation', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it 'returns the form with a clear message when no patient is selected', :aggregate_failures do
    post assessments_path, params: { assessment: { patient_id: '', title: 'Avaliação inicial' } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Selecione um paciente')
    expect(response.body).to include('Paciente deve ser selecionado')
    expect(response.body).to include('Avaliação inicial')
    expect(response.body).not_to include('erro(s)')
  end
end
