require 'rails_helper'

RSpec.describe SharedApiKey, type: :model do
  let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
  
  describe 'validations' do
    it 'requires key' do
      shared_key = SharedApiKey.new(user: user)
      expect(shared_key.valid?).to be false
      expect(shared_key.errors[:key]).to include("can't be blank")
    end
    
    it 'requires unique key' do
      key_value = SecureRandom.urlsafe_base64(32)
      SharedApiKey.create!(user: user, key: key_value)
      duplicate = SharedApiKey.new(user: user, key: key_value)
      expect(duplicate.valid?).to be false
    end
  end
  
  describe 'associations' do
    it 'belongs to user' do
      shared_key = user.shared_api_keys.create!(key: SecureRandom.urlsafe_base64(32))
      expect(shared_key.user).to eq(user)
    end
  end
  
  describe '#deactivate!' do
    it 'sets active to false' do
      shared_key = user.create_shared_key
      expect(shared_key.active).to be true
      
      shared_key.deactivate!
      expect(shared_key.active).to be false
    end
  end
  
  describe '#touch_last_used!' do
    it 'updates last_used_at timestamp' do
      shared_key = user.create_shared_key
      expect(shared_key.last_used_at).to be_nil
      
      shared_key.touch_last_used!
      expect(shared_key.last_used_at).to be_present
    end
  end
  
  describe '.active scope' do
    it 'returns only active keys' do
      active_key = user.create_shared_key
      inactive_key = user.create_shared_key
      inactive_key.deactivate!
      
      expect(SharedApiKey.active).to include(active_key)
      expect(SharedApiKey.active).not_to include(inactive_key)
    end
  end
end