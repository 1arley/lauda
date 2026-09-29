module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :nullify

    after_create { log_audit('create') }
    after_update { log_audit('update') }
    after_destroy { log_audit('destroy') }
  end

  private

  def log_audit(action)
    audit_logs.create!(
      tenant_id: Current.tenant_id,
      user_id: Current.user_id,
      action: action,
      changeset: saved_changes.except('updated_at', 'created_at'),
      metadata: { ip_address: Current.ip_address }
    )
  rescue StandardError => e
    Rails.logger.error("Audit log failed: #{e.message}")
  end
end
