require 'rails_helper'

RSpec.describe 'Documents API', type: :request do
  let(:user) { User.create!(name: 'Test', email: 'test@example.com') }
  let(:vault) { user.vaults.create!(name: 'Test Vault') }
  let(:owner_headers) { { 'Authorization' => "Bearer #{user.owner_api_key}" } }
  let(:shared_key) { user.create_shared_key }
  let(:shared_headers) { { 'Authorization' => "Bearer #{shared_key.key}" } }
  
  describe 'GET /api/v1/vaults/:vault_id/documents' do
    before do
      vault.documents.create!(
        title: 'API Authentication Guide',
        file_path: '/tmp/api_auth.pdf',
        content_type: 'application/pdf',
        metadata: { category: 'technical', tags: ['api', 'authentication'] }
      )
      
      vault.documents.create!(
        title: 'Design System Documentation',
        file_path: '/tmp/design.pdf',
        content_type: 'application/pdf',
        metadata: { category: 'design', tags: ['ui', 'components'] }
      )
      vault.documents.create!(
        title: 'API Rate Limiting',
        file_path: '/tmp/rate_limit.md',
        content_type: 'text/markdown',
        metadata: { category: 'technical', tags: ['api', 'performance'] }
      )
    end
    
    it 'returns all documents with owner key' do
      get "/api/v1/vaults/#{vault.id}/documents", headers: owner_headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.first['access_level']).to eq('full')
    end
    
    it 'returns all documents with shared key' do
      get "/api/v1/vaults/#{vault.id}/documents", headers: shared_headers
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.first['access_level']).to eq('read_only')
    end

    describe 'title search' do
      it 'finds documents by title' do
        get "/api/v1/vaults/#{vault.id}/documents?search=API", headers: shared_headers

        documents = JSON.parse(response.body)
        expect(documents.length).to eq(2)
        titles = documents.map { |d| d['title'] }
        expect(titles).to include('API Authentication Guide', 'API Rate Limiting')
      end
      
      it 'is case insensitive' do
        get "/api/v1/vaults/#{vault.id}/documents?search=api", headers: shared_headers
        
        documents = JSON.parse(response.body)
        expect(documents.length).to eq(2)
      end
    end
      
    describe 'content type filter' do
      it 'filters by content type' do
        get "/api/v1/vaults/#{vault.id}/documents/search?content_type=markdown", headers: owner_headers
        
        json = JSON.parse(response.body)
        expect(json['documents'].length).to eq(1)
        expect(json['documents'].first['title']).to eq('API Rate Limiting')
      end
    end
  end
  
  describe 'POST /api/v1/vaults/:vault_id/documents' do
    let(:file) { fixture_file_upload('test.pdf', 'application/pdf') }
    
    context 'with owner key' do
      it 'creates document' do
        post "/api/v1/vaults/#{vault.id}/documents",
             params: { 
               document: { 
                 title: 'New Doc',
                 file: file
               }
             },
             headers: owner_headers
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('New Doc')
      end
    end
    
    context 'with shared key' do
      it 'prevents creating documents' do
        post "/api/v1/vaults/#{vault.id}/documents",
             params: { document: { title: 'Hacked' } },
             headers: shared_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
  
  describe 'GET /api/v1/vaults/:vault_id/documents/:id/download' do
    let(:document) { vault.documents.create!(title: 'Test', file_path: create_test_file, content_type: "application/pdf") }
    
    def create_test_file
      dir = Rails.root.join('tmp', 'test_files')
      FileUtils.mkdir_p(dir)
      filepath = dir.join('test.pdf')
      File.write(filepath, 'test content')
      filepath.to_s
    end
    
    it 'allows download with owner key' do
      get "/api/v1/vaults/#{vault.id}/documents/#{document.id}/download",
          headers: owner_headers
      
      expect(response).to have_http_status(:ok)
    end
    
    it 'allows download with shared key' do
      get "/api/v1/vaults/#{vault.id}/documents/#{document.id}/download",
          headers: shared_headers
      
      expect(response).to have_http_status(:ok)
    end
  end
  
  describe 'PUT /api/v1/vaults/:vault_id/documents/:id' do
    let(:document) { vault.documents.create!(title: 'Old', file_path: '/tmp/test.pdf') }
    
    context 'with owner key' do
      it 'updates document' do
        put "/api/v1/vaults/#{vault.id}/documents/#{document.id}",
            params: { document: { title: 'Updated' } },
            headers: owner_headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('Updated')
      end
    end
    
    context 'with shared key' do
      it 'prevents updating' do
        put "/api/v1/vaults/#{vault.id}/documents/#{document.id}",
            params: { document: { title: 'Hacked' } },
            headers: shared_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
  
  describe 'DELETE /api/v1/vaults/:vault_id/documents/:id' do
    let(:document) { vault.documents.create!(title: 'To Delete', file_path: '/tmp/test.pdf') }
    
    context 'with owner key' do
      it 'deletes document' do
        delete "/api/v1/vaults/#{vault.id}/documents/#{document.id}",
               headers: owner_headers
        
        expect(response).to have_http_status(:no_content)
        expect(Document.exists?(document.id)).to be false
      end
    end
    
    context 'with shared key' do
      it 'prevents deleting' do
        delete "/api/v1/vaults/#{vault.id}/documents/#{document.id}",
               headers: shared_headers
        
        expect(response).to have_http_status(:forbidden)
        expect(Document.exists?(document.id)).to be true
      end
    end
  end
end