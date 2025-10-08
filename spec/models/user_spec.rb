require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'requires email' do
      user = User.new(name: 'Test')
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include("can't be blank")
    end
    
    it 'requires valid email field' do
      user = User.new(name: 'Test')
      expect(user.valid?).to be false
    end
    
    it 'requires unique email' do
      User.create!(name: 'Test', email: 'test@example.com')
      duplicate = User.new(name: 'Test2', email: 'test@example.com')
      expect(duplicate.valid?).to be false
    end
    
    it 'generates owner API key on creation' do
      user = User.create!(name: 'Test', email: 'test@example.com')
      expect(user.owner_api_key).to be_present
      expect(user.owner_api_key.length).to be > 20
    end
  end
  
  describe '#regenerate_owner_api_key!' do
    it 'generates new owner API key' do
      user = User.create!(name: 'Test', email: 'test@example.com')
      old_key = user.owner_api_key
      user.regenerate_owner_api_key!
      expect(user.owner_api_key).not_to eq(old_key)
    end
  end
  
  describe '#create_shared_key' do
    let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
    
    it 'creates a shared API key' do
      expect {
        user.create_shared_key(name: 'Test Key')
      }.to change(SharedApiKey, :count).by(1)
    end
    
    it 'creates key with unique value' do
      key1 = user.create_shared_key
      key2 = user.create_shared_key
      expect(key1.key).not_to eq(key2.key)
    end
    
    it 'creates active key by default' do
      key = user.create_shared_key
      expect(key.active).to be true
    end
  end
  
  describe '#accessible_vaults' do
    it 'returns owned vaults' do
      user = User.create!(name: 'Test', email: 'test@example.com')
      vault = user.vaults.create!(name: 'My Vault')
      expect(user.accessible_vaults).to include(vault)
    end
  end
end