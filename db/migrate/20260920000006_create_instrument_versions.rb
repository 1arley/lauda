class CreateInstrumentVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :instrument_versions, id: :uuid do |t|
      t.references :instrument, null: false, foreign_key: true, type: :uuid
      t.string :version, null: false
      t.string :norm_name, null: false
      t.string :norm_source
      t.integer :norm_year
      t.jsonb :scoring_config
      t.jsonb :interpretation_rules
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :instrument_versions, [:instrument_id, :version], unique: true
  end
end
