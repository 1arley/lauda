class CreateNormativeTables < ActiveRecord::Migration[8.1]
  def change
    create_table :normative_tables, id: :uuid do |t|
      t.references :instrument_version, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :age_range
      t.string :education_level
      t.jsonb :data, null: false
      t.timestamps
    end
    add_index :normative_tables, [:instrument_version_id, :name]
  end
end
