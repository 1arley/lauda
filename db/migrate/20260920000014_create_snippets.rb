class CreateSnippets < ActiveRecord::Migration[8.1]
  def change
    create_table :snippets, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :content, null: false
      t.string :category
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :snippets, [:tenant_id, :category]
  end
end
