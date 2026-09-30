class Invitation < ApplicationRecord
  belongs_to :tenant
  belongs_to :invited_by, class_name: 'User', optional: true

  acts_as_tenant(:tenant)

  enum :role, User.roles, default: :professional

  # O mesmo conjunto de roles de User, sem `saas_admin`: quem administra uma
  # clínica não cria administrator da plataforma.
  INVITABLE_ROLES = %w[tenant_admin professional reviewer].freeze

  EXPIRES_IN = 7.days

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: INVITABLE_ROLES }
  # Só na criação: no aceite o usuário já existe com esse e-mail, porque é o
  # mesmo `accept!` que o cria, e revalidar ali rejeitaria o próprio convite.
  validate :email_is_free, on: :create

  scope :pending, -> { where(accepted_at: nil).where(expires_at: Time.current..) }

  # O token cru só existe no envio do e-mail; o banco guarda o digest, que é
  # por isso que `token_digest` é gerado antes de validar.
  attr_reader :raw_token

  before_validation :assign_token
  before_validation { self.expires_at ||= EXPIRES_IN.from_now }

  def assign_token
    return if token_digest.present?

    @raw_token, self.token_digest = Devise.token_generator.generate(self.class, :token_digest)
  end

  # Aceita o token cru do e-mail e devolve o convite pendente correspondente.
  # Devolve nil para token desconhecido, já usado ou expirado, sem distinção
  # que revele se o convite existe.
  def self.find_valid(token)
    return if token.blank?

    digest = Devise.token_generator.digest(self, :token_digest, token)
    pending.find_by(token_digest: digest)
  end

  def pending?
    accepted_at.nil? && expires_at.future?
  end

  # Cria o usuário na clínica do convite. O e-mail já foi provado pelo fato de
  # a pessoa ter clicado no link, então a conta nasce confirmada.
  def accept!(attributes)
    user = User.new(
      tenant: tenant,
      email: email,
      role: role,
      name: attributes[:name],
      password: attributes[:password],
      password_confirmation: attributes[:password_confirmation]
    )
    user.skip_confirmation!

    User.transaction do
      user.save!
      update!(accepted_at: Time.current)
    end

    user
  end

  private

  # `users.email` tem índice único global, então um e-mail que já tem conta
  # não pode ser convidado, de nenhuma clínica. A busca ignora o tenant
  # corrente de propósito: o e-mail pode existir em outra clínica e o
  # índice único recusaria o INSERT na hora do aceite.
  def email_is_free
    return if email.blank?
    return unless User.unscoped.exists?(email: email.downcase)

    errors.add(:email, 'já pertence a uma conta')
  end
end
