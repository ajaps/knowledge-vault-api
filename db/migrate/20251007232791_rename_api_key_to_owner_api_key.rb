class RenameApiKeyToOwnerApiKey < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :api_key, :owner_api_key
  end
end