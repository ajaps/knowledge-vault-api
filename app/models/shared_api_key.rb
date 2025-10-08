class SharedApiKey < ApplicationRecord
  belongs_to :user
  
  validates :key, presence: true, uniqueness: true
  
  scope :active, -> { where(active: true) }
  
  def deactivate!
    update!(active: false)
  end
  
  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end
end