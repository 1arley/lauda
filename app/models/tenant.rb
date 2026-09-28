class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :report_templates, dependent: :destroy
  has_many :snippets, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :export_jobs, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true

  def admin_for(user)
    user.saas_admin? || user.tenant_admin?
  end
end
