class Document < ApplicationRecord
  has_many :vaults
  has_many :api_keys
end
