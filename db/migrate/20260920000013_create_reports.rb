class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports, id: :uuid do |t|
      t.references :assessment, null: false, foreign_key: true, type: :uuid
      t.references :report_template, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.integer :status, default: 0, null: false
      t.jsonb :sections, null: false
      t.text :final_text
      t.datetime :finalized_at
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :reports, [:assessment_id, :status]
  end
end
