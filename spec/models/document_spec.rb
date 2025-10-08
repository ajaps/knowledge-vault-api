require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
  let(:vault) { user.vaults.create!(name: 'Test Vault') }
  
  describe 'validations' do
    it 'requires title' do
      doc = Document.new(vault: vault, file_path: '/tmp/test.pdf')
      expect(doc.valid?).to be false
      expect(doc.errors[:title]).to include("can't be blank")
    end
    
    it 'requires file_path' do
      doc = Document.new(title: 'Test', vault: vault)
      expect(doc.valid?).to be false
    end
  end
  
  describe 'scopes' do
    before do
      vault.documents.create!(title: 'Design Doc', file_path: '/tmp/design.pdf')
      vault.documents.create!(title: 'API Spec', file_path: '/tmp/api.pdf')
    end
    
    it 'searches by title' do
      results = vault.documents.search_by_title('Design')
      expect(results.count).to eq(1)
      expect(results.first.title).to eq('Design Doc')
    end
  end
  
  describe '#owner?' do
    it 'returns true for vault owner' do
      doc = vault.documents.create!(title: 'Test', file_path: '/tmp/test.pdf')
      expect(doc.owner?(user)).to be true
    end
    
    it 'returns false for other users' do
      other_user = User.create!(name: 'Other', email: 'other@example.com')
      doc = vault.documents.create!(title: 'Test', file_path: '/tmp/test.pdf')
      expect(doc.owner?(other_user)).to be false
    end
  end
end