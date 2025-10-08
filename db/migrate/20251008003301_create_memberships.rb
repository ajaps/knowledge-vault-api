class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.string :vault
      t.string :references
      t.integer :role

      t.timestamps
    end
    
    add_index :memberships, :role
  end
end
