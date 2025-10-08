class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.references :vault, null: false, foreign_key: true
      t.string :file_path, null: false
      t.string :content_type
      t.integer :file_size
      t.jsonb :metadata, default: {}
      
      t.timestamps
    end
    
    add_index :documents, :vault_id, name: :index_documents_on_vault
    add_index :documents, :metadata, using: :gin
  end
end