class User < ApplicationRecord
  has_secure_password

  has_many :api_keys, dependent: :destroy
  has_many :vaults, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  def issue_jwt
    payload = {
      sub: id, exp: 30.days.from_now.to_i
    }

    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end
end
