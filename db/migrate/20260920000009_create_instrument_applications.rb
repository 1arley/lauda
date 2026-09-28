class CreateInstrumentApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :instrument_applications, id: :uuid do |t|
      t.references :assessment, null: false, foreign_key: true, type: :uuid
      t.references :instrument_version, null: false, foreign_key: true, type: :uuid
      t.references :applied_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.integer :status, default: 0, null: false
      t.datetime :applied_at
      t.datetime :scored_at
      t.text :notes
      t.jsonb :metadata
      t.timestamps
    end
    add_index :instrument_applications, [:assessment_id, :instrument_version_id]
  end
end
