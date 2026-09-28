class ReportTemplate < ApplicationRecord
  include Discard::Model

  belongs_to :tenant
  has_many :reports, dependent: :destroy

  validates :name, presence: true
  validates :sections, presence: true

  after_initialize { self.sections ||= [] }

  acts_as_tenant(:tenant)

  def self.default_for(tenant)
    where(tenant: tenant, default: true).first
  end
end
