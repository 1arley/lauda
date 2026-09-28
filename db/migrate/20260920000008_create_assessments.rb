class CreateAssessments < ActiveRecord::Migration[8.1]
  def change
    create_table :assessments, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :patient, null: false, foreign_key: true, type: :uuid
      t.references :owner, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.integer :status, default: 0, null: false
      t.string :title
      t.text :context
      t.datetime :conducted_at
      t.datetime :finalized_at
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :assessments, [:tenant_id, :status]
    add_index :assessments, [:tenant_id, :patient_id]
    add_index :assessments, [:tenant_id, :discarded_at]
  end
end
