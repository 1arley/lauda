require 'rails_helper'

RSpec.describe 'Report template creation', type: :request do
  let(:user) { create(:user, :tenant_admin) }

  before { sign_in user }

  it 'shows which required information is missing when no section is submitted' do
    post report_templates_path, params: {
      report_template: { name: 'Laudo psicológico', description: 'Descrição preenchida' }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Adicione pelo menos uma seção com título ao template.')
    expect(response.body).to include('Laudo psicológico')
    expect(response.body).to include('Descrição preenchida')
  end

  it 'creates a template with a section entered in the form' do
    get new_report_template_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Título da seção')

    post report_templates_path, params: {
      report_template: {
        name: 'Laudo psicológico',
        description: 'Descrição preenchida',
        sections: [{ title: 'Identificação', content: 'Dados do paciente', section_type: 'text' }]
      }
    }

    expect(response).to redirect_to(report_templates_path)
    expect(ReportTemplate.last.sections.first['title']).to eq('Identificação')

    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Template criado.')
  end
end
