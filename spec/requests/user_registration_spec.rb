require 'rails_helper'

RSpec.describe 'User registration', type: :request do
  describe 'POST /users' do
    let(:attributes) do
      {
        tenant_name: 'Clínica Exemplo',
        subdomain: 'clinica-exemplo',
        name: 'Ana Profissional',
        email: 'ana@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end
    let(:registered_user) { User.find_by!(email: 'ana@example.com') }

    it 'creates the clinic and its tenant admin together' do
      post user_registration_path, params: { user: attributes }

      expect(registered_user).to have_attributes(
        name: 'Ana Profissional', role: 'tenant_admin',
        tenant: have_attributes(name: 'Clínica Exemplo', subdomain: 'clinica-exemplo')
      )
    end

    it 'does not leave a clinic behind when registration is invalid' do
      attributes[:subdomain] = 'invalid subdomain'

      expect do
        post user_registration_path, params: { user: attributes }
      end.not_to(change { [Tenant.count, User.count] })
    end
  end
end
