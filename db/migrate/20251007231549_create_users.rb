class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :api_key, null: false
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :api_key, unique: true
  end
end