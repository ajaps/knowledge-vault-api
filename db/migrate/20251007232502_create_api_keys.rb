class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys do |t|
      t.string :token
      t.references :user, null: false, foreign_key: true
      t.datetime :last_seen

      t.timestamps
    end
  end
end
