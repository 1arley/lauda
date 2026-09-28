class CreateScoreResults < ActiveRecord::Migration[8.1]
  def change
    create_table :score_results, id: :uuid do |t|
      t.references :instrument_application, null: false, foreign_key: true, type: :uuid
      t.references :normative_table, null: false, foreign_key: true, type: :uuid
      t.string :subtest_name
      t.integer :position
      t.decimal :raw_score, precision: 10, scale: 2
      t.decimal :scaled_score, precision: 10, scale: 2
      t.decimal :percentile, precision: 10, scale: 2
      t.string :classification
      t.jsonb :details
      t.datetime :computed_at, null: false
      t.timestamps
    end
    add_index :score_results, [:instrument_application_id, :subtest_name]
  end
end
