class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.date :birth_date
      t.string :cpf
      t.string :gender
      t.string :email
      t.string :phone
      t.text :notes
      t.jsonb :metadata
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :patients, [:tenant_id, :name]
    add_index :patients, [:tenant_id, :discarded_at]
    add_index :patients, [:tenant_id, :cpf], unique: true, where: "cpf IS NOT NULL"
  end
end
