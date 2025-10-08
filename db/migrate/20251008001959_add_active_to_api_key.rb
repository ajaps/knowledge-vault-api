class AddActiveToApiKey < ActiveRecord::Migration[8.0]
  def change
    add_column :api_keys, :active, :boolean
  end
end
