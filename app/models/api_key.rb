class ApiKey < ApplicationRecord
  belongs_to :user

  scope :active, -> { where (active: true) }
  
  def self.generate!(user)
    raw = SecureRandom.hex(32)
    create!(user: user, token: digest(raw), last_seen: nil)

    raw
  end

  def revoke!
    update!(active: false)
  end

  def self.digest(raw)
    OpenSSL::Digest::SHA256.hexdigest(raw)
  end
end
