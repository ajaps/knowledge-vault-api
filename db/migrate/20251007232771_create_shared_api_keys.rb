class CreateSharedApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_api_keys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :key, null: false
      t.boolean :active, default: true
      t.datetime :last_used_at
      
      t.timestamps
    end
    
    add_index :shared_api_keys, :key, unique: true
    add_index :shared_api_keys, [:user_id, :active]
  end
end