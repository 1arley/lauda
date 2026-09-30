require 'rails_helper'

RSpec.describe 'Convite de usuario', type: :request do
  # `deliver_later` enfileira; sem executar a fila o e-mail nunca é entregue.
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:tenant) { create(:tenant, name: 'Clinica Exemplo') }
  let(:admin) { create(:user, :tenant_admin, tenant: tenant) }
  let(:professional) { create(:user, :professional, tenant: tenant) }
  let(:raw_token) { 'token-cru-do-email' }

  # Cria um convite cujo token cru conhecido é `raw_token`, que é o que o
  # e-mail carrega e o que o spec exercita como prova de identidade. O digest
  # é forjado direto no INSERT porque o gerador é aleatório.
  def create_invitation(email:, role: 'professional', tenant: self.tenant, invited_by: nil)
    Invitation.create!(
      tenant: tenant, invited_by: invited_by, email: email, role: role,
      token_digest: Devise.token_generator.digest(Invitation, :token_digest, raw_token)
    )
  end

  describe 'POST /invitations pelo admin da clinica' do
    before { sign_in admin }

    it 'cria o convite, envia o e-mail e nao guarda o token cru', :aggregate_failures do
      expect do
        post invitations_path, params: { invitation: { email: 'nova@example.com', role: 'reviewer' } }
      end.to change(Invitation, :count).by(1)
                                       .and change { ActionMailer::Base.deliveries.size }.by(1)

      expect(response).to redirect_to(new_invitation_path)

      invitation = Invitation.last
      expect(invitation).to have_attributes(email: 'nova@example.com', role: 'reviewer', tenant: tenant,
                                            invited_by: admin, accepted_at: nil)
      expect(invitation.token_digest).to be_present
      expect(invitation.token_digest).not_to eq(raw_token)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq(['nova@example.com'])
      # multipart: o link está no html_part e no text_part.
      expect(mail.html_part.body.to_s).to include('/convites/aceitar?token=')
      expect(mail.text_part.body.to_s).to include('/convites/aceitar?token=')
    end

    it 'recusa e-mail que ja pertence a uma conta', :aggregate_failures do
      expect do
        post invitations_path, params: { invitation: { email: professional.email, role: 'professional' } }
      end.not_to change(Invitation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'recusa role de administrador da plataforma', :aggregate_failures do
      expect do
        post invitations_path, params: { invitation: { email: 'novo@example.com', role: 'saas_admin' } }
      end.not_to change(Invitation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'convite por profissional comum' do
    before { sign_in professional }

    it 'nega a criacao de convite', :aggregate_failures do
      expect do
        post invitations_path, params: { invitation: { email: 'nova@example.com', role: 'professional' } }
      end.not_to change(Invitation, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'aceite sem sessao' do
    it 'cria o usuario na clinica do convite, ja confirmado e logado', :aggregate_failures do
      invitation = create_invitation(email: 'nova@example.com', role: 'reviewer', invited_by: admin)

      get accept_invitation_path(token: raw_token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('nova@example.com')

      patch accept_invitation_path(token: raw_token), params: {
        registration: { name: 'Nova Revisora', password: 'password123', password_confirmation: 'password123' }
      }

      created = User.unscoped.find_by!(email: 'nova@example.com')
      expect(created).to have_attributes(name: 'Nova Revisora', role: 'reviewer', tenant: tenant)
      expect(created.confirmed_at).to be_present
      expect(invitation.reload.accepted_at).to be_present
      expect(response).to redirect_to(root_path)
    end

    it 'recusa token invalido, expirado ou ja usado', :aggregate_failures do
      invitation = create_invitation(email: 'nova@example.com')

      get accept_invitation_path(token: 'token-errado')
      expect(response).to redirect_to(new_user_session_path)

      invitation.update!(expires_at: 1.day.ago)
      get accept_invitation_path(token: raw_token)
      expect(response).to redirect_to(new_user_session_path)

      invitation.update!(expires_at: 7.days.from_now, accepted_at: Time.current)
      get accept_invitation_path(token: raw_token)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'nao cria o usuario quando a senha nao confere', :aggregate_failures do
      invitation = create_invitation(email: 'nova@example.com')

      patch accept_invitation_path(token: raw_token), params: {
        registration: { name: 'Nova Profissional', password: 'password123', password_confirmation: 'outra' }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(User.unscoped.find_by(email: 'nova@example.com')).to be_nil
      expect(invitation.reload.accepted_at).to be_nil
    end
  end
end
