class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  belongs_to :tenant, inverse_of: :users
  has_many :owned_assessments, class_name: 'Assessment', foreign_key: :owner_id, dependent: :nullify, inverse_of: :owner
  has_many :applied_instruments, class_name: 'InstrumentApplication', foreign_key: :applied_by_id, dependent: :nullify, inverse_of: :applied_by
  has_many :created_reports, class_name: 'Report', foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :export_jobs, dependent: :nullify
  has_many :audit_logs, dependent: :nullify

  enum :role, { saas_admin: 0, tenant_admin: 1, professional: 2, reviewer: 3 }

  validates :name, presence: true
  validates :role, presence: true

  scope :active_users, -> { kept.where(active: true) }

  acts_as_tenant(:tenant)
end
