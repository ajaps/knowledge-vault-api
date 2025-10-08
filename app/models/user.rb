class User < ApplicationRecord
  has_many :vaults, dependent: :destroy
  has_many :shared_api_keys, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :owner_api_key, presence: true, uniqueness: true
  
  before_validation :generate_owner_api_key, on: :create
  
  def accessible_vaults
    Vault.where(user_id: id)
  end
  
  def regenerate_owner_api_key!
    self.owner_api_key = self.class.generate_unique_key
    save!
  end
  
  def create_shared_key(name: nil)
    shared_api_keys.create!(
      key: self.class.generate_unique_key,
    )
  end
  
  private
  
  def generate_owner_api_key
    self.owner_api_key ||= self.class.generate_unique_key
  end
  
  def self.generate_unique_key
    loop do
      key = SecureRandom.urlsafe_base64(32)
      break key unless User.exists?(owner_api_key: key) || SharedApiKey.exists?(key: key)
    end
  end
end