class Patient < ApplicationRecord
  include Discard::Model
  include Auditable

  belongs_to :tenant
  has_many :assessments, dependent: :destroy

  validates :name, presence: true
  validates :cpf, uniqueness: { scope: :tenant_id }, allow_blank: true

  acts_as_tenant(:tenant)

  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") }

  def age
    return nil unless birth_date

    ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
  end
end
