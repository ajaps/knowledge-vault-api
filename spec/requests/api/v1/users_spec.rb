require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST /api/v1/users' do
    it 'creates a new user with owner API key' do
      post '/api/v1/users', params: {
        user: {
          email: 'test@example.com',
          name: 'Test User'
        }
      }
      
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['email']).to eq('test@example.com')
      expect(json['owner_api_key']).to be_present
      expect(json['key_type']).to eq('owner')
    end
    
    it 'returns errors for invalid user' do
      post '/api/v1/users', params: {
        user: {
          name: 'Test'
        }
      }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  
  describe 'GET /api/v1/users/me' do
    let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
    
    context 'with owner key' do
      it 'returns current user with owner_api_key' do
        get '/api/v1/users/me', headers: { 'Authorization' => "Bearer #{user.owner_api_key}" }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['email']).to eq(user.email)
        expect(json['owner_api_key']).to eq(user.owner_api_key)
        expect(json['key_type']).to eq('owner')
      end
    end
    
    context 'with shared key' do
      let(:shared_key) { user.create_shared_key }
      
      it 'returns current user without owner_api_key' do
        get '/api/v1/users/me', headers: { 'Authorization' => "Bearer #{shared_key.key}" }
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['email']).to eq(user.email)
        expect(json['owner_api_key']).to be_nil
        expect(json['key_type']).to eq('shared')
      end
    end
    
    it 'requires authentication' do
      get '/api/v1/users/me'
      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  describe 'POST /api/v1/users/regenerate_owner_api_key' do
    let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
    
    it 'generates new owner API key' do
      old_key = user.owner_api_key
      post '/api/v1/users/regenerate_owner_api_key', 
           headers: { 'Authorization' => "Bearer #{old_key}" }
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['owner_api_key']).not_to eq(old_key)
    end
    
    it 'requires owner key' do
      shared_key = user.create_shared_key
      post '/api/v1/users/regenerate_owner_api_key',
           headers: { 'Authorization' => "Bearer #{shared_key.key}" }
      
      expect(response).to have_http_status(:forbidden)
    end
  end
  
  describe 'POST /api/v1/users/shared_keys' do
    let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
    
    it 'creates shared key with owner key' do
      post '/api/v1/users/shared_keys',
           headers: { 'Authorization' => "Bearer #{user.owner_api_key}" }
      
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['key']).to be_present
      expect(json['active']).to be true
    end
    
    it 'requires owner key' do
      shared_key = user.create_shared_key
      post '/api/v1/users/shared_keys',
           headers: { 'Authorization' => "Bearer #{shared_key.key}" }
      
      expect(response).to have_http_status(:forbidden)
    end
  end
  
  describe 'GET /api/v1/users/shared_keys' do
    let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
    
    before do
      user.create_shared_key(name: 'Key 1')
      user.create_shared_key(name: 'Key 2')
    end
    
    it 'lists all shared keys' do
      get '/api/v1/users/shared_keys',
          headers: { 'Authorization' => "Bearer #{user.owner_api_key}" }
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json.map { |k| k['id'] }).to match_array([user.shared_api_keys.first.id, user.shared_api_keys.second.id])
    end
    
    it 'requires owner key' do
      shared_key = user.shared_api_keys.first
      get '/api/v1/users/shared_keys',
          headers: { 'Authorization' => "Bearer #{shared_key.key}" }
      
      expect(response).to have_http_status(:forbidden)
    end
  end
  
  describe 'DELETE /api/v1/users/shared_keys/:id' do
    let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
    let(:shared_key) { user.create_shared_key }
    
    it 'deactivates shared key' do
      delete "/api/v1/users/shared_keys/#{shared_key.id}",
             headers: { 'Authorization' => "Bearer #{user.owner_api_key}" }
      
      expect(response).to have_http_status(:no_content)
      expect(shared_key.reload.active).to be false
    end
    
    it 'requires owner key' do
      another_shared_key = user.create_shared_key
      delete "/api/v1/users/shared_keys/#{shared_key.id}",
             headers: { 'Authorization' => "Bearer #{another_shared_key.key}" }
      
      expect(response).to have_http_status(:forbidden)
    end
  end
end
