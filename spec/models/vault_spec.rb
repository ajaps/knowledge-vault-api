require 'rails_helper'

RSpec.describe Vault, type: :model do
  let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
  
  describe 'validations' do
    it 'requires name' do
      vault = Vault.new(user: user)
      expect(vault.valid?).to be false
      expect(vault.errors[:name]).to include("can't be blank")
    end
    
    it 'requires user' do
      vault = Vault.new(name: 'Test Vault')
      expect(vault.valid?).to be false
    end
  end
  
  describe 'associations' do
    it 'belongs to user' do
      vault = user.vaults.create!(name: 'Test')
      expect(vault.user).to eq(user)
    end
    
    it 'has many documents' do
      vault = user.vaults.create!(name: 'Test')
      expect(vault).to respond_to(:documents)
    end
  end
end