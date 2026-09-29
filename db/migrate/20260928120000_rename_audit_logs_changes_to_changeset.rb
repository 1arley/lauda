class RenameAuditLogsChangesToChangeset < ActiveRecord::Migration[8.1]
  # A coluna chamava-se "changes", que colide com o método changes do Active Record:
  # qualquer auditoria falhava com DangerousAttributeError e era engolida pelo rescue.
  def change
    rename_column :audit_logs, :changes, :changeset
  end
end
