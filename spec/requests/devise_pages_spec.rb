require 'rails_helper'

# Regressões das telas de autenticação. Cada example aqui cobriu um defeito real
# que só apareceu em produção: o importmap vazio (Turbo/Stimulus não carregavam)
# e o login falhado sem nenhuma mensagem na tela.
RSpec.describe 'Devise authentication pages', type: :request do
  let(:user) { create(:user) }

  describe 'GET /users/sign_in' do
    it 'publica o importmap com Turbo e Stimulus' do
      get new_user_session_path

      expect(response.body).to include('"@hotwired/turbo-rails"', '"@hotwired/stimulus"')
    end
  end

  describe 'POST /users/sign_in' do
    it 'diz que as credenciais não batem em vez de recarregar o formulário em silêncio' do
      post user_session_path, params: { user: { email: user.email, password: 'senha-errada' } }

      expect(response.body).to include('E-mail ou senha inválidos')
    end

    it 'deixa o usuário autenticado acessar o dashboard' do
      post user_session_path, params: { user: { email: user.email, password: 'password123' } }

      expect(response).to redirect_to(assessments_path)
    end
  end
end
