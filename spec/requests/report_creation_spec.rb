require 'rails_helper'

RSpec.describe 'Report creation', type: :request do
  let(:user) { create(:user) }
  let(:assessment) do
    create(:assessment, tenant: user.tenant, owner: user, patient: create(:patient, tenant: user.tenant))
  end

  before { sign_in user }

  it 'returns the report form with an explicit template error when none is selected', :aggregate_failures do
    post assessment_reports_path(assessment), params: { report: { report_template_id: '' } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Template deve ser selecionado')
    expect(response.body).to include('Selecione um template')
    expect(response.body).not_to include('erro(s)')
  end

  it 'copies template sections into the report and saves edits from the report form', :aggregate_failures do
    template = ReportTemplate.create!(tenant: user.tenant, name: 'Template', sections: [
                                        { 'title' => 'Resumo', 'content' => 'Texto inicial', 'section_type' => 'text' }
                                      ])

    post assessment_reports_path(assessment), params: { report: { report_template_id: template.id } }

    report = Report.last
    expect(response).to redirect_to(edit_assessment_report_path(assessment, report))
    expect(report.sections.first['title']).to eq('Resumo')

    patch assessment_report_path(assessment, report), params: {
      report: { sections: [{ title: 'Resumo', content: 'Texto final', section_type: 'text' }] }
    }

    expect(response).to redirect_to(edit_assessment_report_path(assessment, report))
    expect(report.reload.sections.first['content']).to eq('Texto final')
  end
end
