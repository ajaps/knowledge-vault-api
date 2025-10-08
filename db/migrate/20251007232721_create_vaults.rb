class CreateVaults < ActiveRecord::Migration[8.0]
  def change
    create_table :vaults do |t|
      t.string :name, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :vaults, :user_id, name: :index_vaults_on_user
  end
end
