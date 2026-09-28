class CreateExportJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :export_jobs, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :report, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :status, default: 0, null: false
      t.string :format, null: false, default: "pdf"
      t.string :file_url
      t.string :error_message
      t.datetime :completed_at
      t.timestamps
    end
    add_index :export_jobs, [:tenant_id, :status]
    add_index :export_jobs, [:report_id, :status]
  end
end
