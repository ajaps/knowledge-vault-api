class Vault < ApplicationRecord
  belongs_to :user
  has_many :documents
end
