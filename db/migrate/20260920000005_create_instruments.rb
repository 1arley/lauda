class CreateInstruments < ActiveRecord::Migration[8.1]
  def change
    create_table :instruments, id: :uuid do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.string :author
      t.string :publisher
      t.integer :category, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :config
      t.timestamps
    end
    add_index :instruments, :code, unique: true
  end
end
