class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :vault
  enum role: { reader: 0, editor: 1, owner: 2 }
  validates :user_id, uniqueness: { scope: :vault_id }
end
