# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.

Devise.setup do |config|
  # Sem secret_key hardcoded: Devise usa Rails.application.secret_key_base por padrão
  # (devise/rails.rb), que vem de credentials/SECRET_KEY_BASE.

  config.mailer_sender = ENV.fetch('MAILER_SENDER', 'noreply@lauda.app')

  require 'devise/orm/active_record'

  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  config.stretches = 12
  # pepper faz parte do hash de senha: trocar invalida todas as senhas existentes.
  config.reconfirmable = true
  config.confirm_within = 2.days

  config.remember_for = 30.days

  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  # Sem :html aqui o Devise responde 401 com "You need to sign in..." em vez de
  # redirecionar, e o fluxo de login pelo navegador (ex.: / -> /users/sign_in)
  # nunca acontece. Mantem */* fora de proposito: o devise-jwt cuida das chamadas
  # de API, que devem continuar devolvendo 401 em JSON.
  config.navigational_formats = [:html]

  config.sign_out_via = :delete

  config.parent_controller = 'ApplicationController'
end
