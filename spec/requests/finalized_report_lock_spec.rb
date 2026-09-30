require 'rails_helper'

RSpec.describe 'Laudo finalizado nao pode ser editado', type: :request do
  let(:user) { create(:user) }
  let(:assessment) do
    create(:assessment, tenant: user.tenant, owner: user, patient: create(:patient, tenant: user.tenant))
  end
  let(:template) do
    ReportTemplate.create!(tenant: user.tenant, name: 'Template', sections: [
                             { 'title' => 'Resumo', 'content' => 'Texto', 'section_type' => 'text' }
                           ])
  end
  let(:report) do
    Report.create!(assessment: assessment, report_template: template, created_by: user,
                   sections: [{ 'title' => 'Resumo', 'content' => 'Original', 'section_type' => 'text' }])
  end

  before { sign_in user }

  it 'recusa GET edit, PATCH update e refinalizacao depois do laudo ficar final', :aggregate_failures do
    post finalize_assessment_report_path(assessment, report)
    expect(report.reload).to be_final

    get edit_assessment_report_path(assessment, report)
    expect(response).to redirect_to(root_path)

    patch assessment_report_path(assessment, report), params: {
      report: { sections: [{ title: 'Resumo', content: 'Alterado depois de finalizar', section_type: 'text' }] }
    }
    expect(response).to redirect_to(root_path)
    expect(report.reload.sections.first['content']).to eq('Original')

    post finalize_assessment_report_path(assessment, report)
    expect(response).to redirect_to(root_path)
  end
end
