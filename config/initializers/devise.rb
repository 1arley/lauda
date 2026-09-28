# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.

Devise.setup do |config|
  # Sem secret_key hardcoded: Devise usa Rails.application.secret_key_base por padrão
  # (devise/rails.rb), que vem de credentials/SECRET_KEY_BASE.

  config.mailer_sender = 'noreply@laudos-saas.com'

  require 'devise/orm/active_record'

  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  config.stretches = 12
  # pepper faz parte do hash de senha: trocar invalida todas as senhas existentes.
  config.pepper = '295dc254fd7cea16edfbee30de1961600ea28d57c0a87d2b6099c798653584de6bfeb0a3af13c8ca7170baeec6deb71442fe03f6ebfcf383b8ee721e6a87e69f' # rubocop:disable Layout/LineLength

  config.reconfirmable = true
  config.confirm_within = 2.days

  config.remember_for = 30.days

  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.navigational_formats = []

  config.sign_out_via = :delete

  config.parent_controller = 'ApplicationController'
end
