class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :auditable_type, null: false
      t.uuid :auditable_id, null: false
      t.string :action, null: false
      t.jsonb :changes
      t.jsonb :metadata
      t.datetime :created_at, null: false
    end
    add_index :audit_logs, [:tenant_id, :created_at]
    add_index :audit_logs, [:auditable_type, :auditable_id]
    add_index :audit_logs, [:tenant_id, :auditable_type, :auditable_id]
  end
end
