require 'rails_helper'

RSpec.describe 'Vaults API', type: :request do
  let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
  let(:owner_headers) { { 'Authorization' => "Bearer #{user.owner_api_key}" } }
  let(:shared_key) { user.create_shared_key }
  let(:shared_headers) { { 'Authorization' => "Bearer #{shared_key.key}" } }
  
  describe 'GET /api/v1/vaults' do
    before do
      user.vaults.create!(name: 'Vault 1')
      user.vaults.create!(name: 'Vault 2')
    end
    
    context 'with owner key' do
      it 'returns user vaults with full access' do
        get '/api/v1/vaults', headers: owner_headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json.first['access_level']).to eq('full')
      end
    end
    
    context 'with shared key' do
      it 'returns user vaults with read_only access' do
        get '/api/v1/vaults', headers: shared_headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json.first['access_level']).to eq('read_only')
      end
    end
    
    it 'requires authentication' do
      get '/api/v1/vaults'
      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  describe 'POST /api/v1/vaults' do
    context 'with owner key' do
      it 'creates a new vault' do
        post '/api/v1/vaults', 
             params: { vault: { name: 'New Vault', description: 'Test' } },
             headers: owner_headers
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('New Vault')
        expect(json['access_level']).to eq('full')
      end
    end
    
    context 'with shared key' do
      it 'prevents creating vaults' do
        post '/api/v1/vaults',
             params: { vault: { name: 'Hacked Vault' } },
             headers: shared_headers
        
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to include('owner API key')
      end
    end
  end
  
  describe 'GET /api/v1/vaults/:id' do
    let(:vault) { user.vaults.create!(name: 'Test Vault') }
    
    it 'returns vault details with owner key' do
      get "/api/v1/vaults/#{vault.id}", headers: owner_headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Test Vault')
      expect(json['access_level']).to eq('full')
    end
    
    it 'returns vault details with shared key' do
      get "/api/v1/vaults/#{vault.id}", headers: shared_headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['access_level']).to eq('read_only')
    end
  end
  
  describe 'PUT /api/v1/vaults/:id' do
    let(:vault) { user.vaults.create!(name: 'Old Name') }
    
    context 'with owner key' do
      it 'updates vault' do
        put "/api/v1/vaults/#{vault.id}",
            params: { vault: { name: 'New Name' } },
            headers: owner_headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('New Name')
      end
    end
    
    context 'with shared key' do
      it 'prevents updating' do
        put "/api/v1/vaults/#{vault.id}",
            params: { vault: { name: 'Hacked' } },
            headers: shared_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
  
  describe 'DELETE /api/v1/vaults/:id' do
    let(:vault) { user.vaults.create!(name: 'To Delete') }
    
    context 'with owner key' do
      it 'deletes vault' do
        delete "/api/v1/vaults/#{vault.id}", headers: owner_headers
        
        expect(response).to have_http_status(:no_content)
        expect(Vault.exists?(vault.id)).to be false
      end
    end
    
    context 'with shared key' do
      it 'prevents deleting' do
        delete "/api/v1/vaults/#{vault.id}", headers: shared_headers
        
        expect(response).to have_http_status(:forbidden)
        expect(Vault.exists?(vault.id)).to be true
      end
    end
  end
end