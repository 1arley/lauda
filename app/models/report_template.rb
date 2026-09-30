class ReportTemplate < ApplicationRecord
  include Discard::Model

  belongs_to :tenant
  has_many :reports, dependent: :destroy

  validates :name, presence: true
  validate :at_least_one_section_with_title?

  after_initialize { self.sections ||= [] }

  acts_as_tenant(:tenant)

  scope :active_templates, -> { kept.where(active: true) }

  def self.default_for(tenant)
    where(tenant: tenant, default: true).first
  end

  private

  def at_least_one_section_with_title?
    return true if sections.is_a?(Array) && sections.any? { |section| section.is_a?(Hash) && section['title'].present? }

    errors.add(:base, 'Adicione pelo menos uma seção com título ao template.')
    false
  end
end
