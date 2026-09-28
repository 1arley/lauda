class CreateReportTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :report_templates, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.text :description
      t.jsonb :sections, null: false
      t.boolean :default, default: false, null: false
      t.boolean :active, default: true, null: false
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :report_templates, [:tenant_id, :name]
  end
end
