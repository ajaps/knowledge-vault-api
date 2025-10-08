class Vault < ApplicationRecord
  belongs_to :user
  has_many :documents, dependent: :destroy
  
  validates :name, presence: true
  validates :user_id, presence: true
  
  scope :by_user, ->(user_id) { where(user_id: user_id) }
end