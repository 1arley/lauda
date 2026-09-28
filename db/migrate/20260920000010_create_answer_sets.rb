class CreateAnswerSets < ActiveRecord::Migration[8.1]
  def change
    create_table :answer_sets, id: :uuid do |t|
      t.references :instrument_application, null: false, foreign_key: true, type: :uuid
      t.string :subtest_name
      t.integer :position
      t.jsonb :answers, null: false
      t.jsonb :metadata
      t.timestamps
    end
    add_index :answer_sets, [:instrument_application_id, :subtest_name]
  end
end
