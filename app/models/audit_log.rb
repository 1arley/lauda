class AuditLog < ApplicationRecord
  belongs_to :tenant
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true

  acts_as_tenant(:tenant)

  scope :recent, -> { order(created_at: :desc) }
  scope :for_entity, ->(type, id) { where(auditable_type: type, auditable_id: id) }
end
