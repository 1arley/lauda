class Patient < ApplicationRecord
  include Discard::Model
  include Auditable

  belongs_to :tenant
  has_many :assessments, dependent: :destroy

  validates :name, presence: true
  validates :cpf, uniqueness: { scope: :tenant_id }, allow_blank: true

  acts_as_tenant(:tenant)

  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") }

  # Ransack exige allowlist explícita: a busca da listagem é só por nome.
  def self.ransackable_attributes(*)
    %w[name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  # Idade em anos completos por calendário. Dividir o tempo decorrido em anos
  # perde um ano quando o horário de hoje é anterior ao do aniversário.
  def age
    return nil unless birth_date

    today = Date.current
    years = today.year - birth_date.year
    years -= 1 if today < birth_date + years.years
    years
  end
end
