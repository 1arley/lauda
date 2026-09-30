require 'rails_helper'

# Auditoria de tratamento de erros: toda submissão inválida deve terminar em
# 422 com o formulário e uma mensagem explícita, ou redirect com flash —
# nunca em 400/404/406/500.
RSpec.describe 'Error handling audit', type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :tenant_admin, tenant: tenant) }
  let(:assessment) { create(:assessment, tenant: tenant, owner: user, patient: create(:patient, tenant: tenant)) }

  before { sign_in user }

  describe 'avaliação' do
    it 'renderiza o formulário de edição (view existe)' do
      get edit_assessment_path(assessment)

      expect(response).to have_http_status(:ok)
    end

    it 're-renderiza o formulário com mensagem ao atualizar com dados inválidos', :aggregate_failures do
      patch assessment_path(assessment), params: { assessment: { patient_id: '', title: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Revise os campos abaixo:')
    end
  end

  describe 'laudo' do
    it 'mostra erro ao criar sem template selecionado', :aggregate_failures do
      post assessment_reports_path(assessment), params: { report: { report_template_id: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Revise os campos abaixo:')
    end

    it 'mostra erro ao atualizar com template inválido (re-render de edit)', :aggregate_failures do
      template = ReportTemplate.create!(tenant: tenant, name: 'Modelo', sections: [{ 'title' => 'Resumo' }])
      report = assessment.reports.create!(report_template: template, created_by: user)

      patch assessment_report_path(assessment, report), params: { report: { report_template_id: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Revise os campos abaixo:')
    end
  end

  describe 'instrumento aplicado' do
    it 'mostra erro ao adicionar sem versão selecionada', :aggregate_failures do
      post assessment_instrument_applications_path(assessment),
           params: { instrument_application: { instrument_version_id: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Selecione um instrumento')
    end
  end

  describe 'template de laudo' do
    it 'redireciona para a lista após criar (não existe página show)', :aggregate_failures do
      post report_templates_path,
           params: { report_template: { name: 'Modelo',
                                        sections: [{ title: 'Resumo', content: '', section_type: 'text' }] } }

      expect(response).to redirect_to(report_templates_path)

      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Template criado.')
    end
  end

  describe 'dados ausentes no request' do
    it 'responde com mensagem explícita em vez de página de erro', :aggregate_failures do
      patch assessment_path(assessment), params: {}

      expect(response).to have_http_status(:found)
      expect(flash[:alert]).to be_present

      follow_redirect!
      expect(response.body).to include('Requisição inválida')
    end
  end
end
