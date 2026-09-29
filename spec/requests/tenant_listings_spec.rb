require 'rails_helper'

RSpec.describe 'Tenant listings', type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:other_tenant) { create(:tenant) }

  before { sign_in user }

  describe 'patients' do
    let!(:own_patient) { create(:patient, tenant: tenant, name: 'Paciente da clínica') }
    let!(:other_patient) { create(:patient, tenant: other_tenant, name: 'Paciente de outra clínica') }

    it 'renders this tenant patients only' do
      get patients_path

      expect([response.status, response.body.include?(own_patient.name), response.body.include?(other_patient.name)])
        .to eq([200, true, false])
    end
  end

  describe 'snippets' do
    let!(:own_snippet) { Snippet.create!(tenant: tenant, title: 'Snippet da clínica', content: 'Texto próprio') }
    let!(:other_snippet) do
      Snippet.create!(tenant: other_tenant, title: 'Snippet de outra clínica', content: 'Texto alheio')
    end

    it 'renders this tenant snippets only' do
      get snippets_path

      expect([response.status, response.body.include?(own_snippet.title), response.body.include?(other_snippet.title)])
        .to eq([200, true, false])
    end
  end

  describe 'report templates' do
    let!(:own_template) do
      ReportTemplate.create!(tenant: tenant, name: 'Template da clínica', sections: [{ 'title' => 'Resumo' }])
    end
    let!(:other_template) do
      ReportTemplate.create!(
        tenant: other_tenant, name: 'Template de outra clínica', sections: [{ 'title' => 'Resumo' }]
      )
    end

    it 'renders this tenant report templates only' do
      get report_templates_path

      expect([response.status, response.body.include?(own_template.name), response.body.include?(other_template.name)])
        .to eq([200, true, false])
    end
  end

  it 'redirects to sign in on every listing' do
    sign_out user

    [patients_path, snippets_path, report_templates_path].each do |path|
      get path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  it 'answers unauthorized to unauthenticated JSON requests' do
    sign_out user

    [patients_path, snippets_path, report_templates_path].each do |path|
      get path, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
