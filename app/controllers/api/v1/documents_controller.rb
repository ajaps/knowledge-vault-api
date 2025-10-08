module Api
  module V1
    class DocumentsController < ApplicationController
      before_action :set_vault
      before_action :set_document, only: [:show, :update, :destroy, :download]
      before_action :require_owner_key!, only: [:create, :update, :destroy]
      
      def index
        @documents = @vault.documents
                           .search_by_title(params[:search])
                           .by_category(params[:category])
                           .by_tag(params[:tag])
                           
        render json: @documents.map { |d| document_response(d) }
      end
      
      def show
        render json: document_response(@document)
      end
      
      def create
        @document = @vault.documents.new(document_params)
        
        if params[:document][:file].present?
          file = params[:document][:file]
          @document.file_path = save_file(file)
          @document.content_type = file.content_type
          @document.file_size = file.size
        end
        
        if @document.save
          render json: document_response(@document), status: :created
        else
          render json: { errors: @document.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def search
        @documents = @vault.documents.full_text_search(params[:q])
        @documents = apply_search_filters(@documents)
        @documents = @documents.sort_by_param(params[:sort])
        
        render json: {
          query: params[:q],
          count: @documents.count,
          documents: @documents.map { |d| document_response(d) }
        }
      end

      def update
        update_params = document_params
        
        if params[:document][:file].present?
          File.delete(@document.file_path) if @document.file_path && File.exist?(@document.file_path)
          
          file = params[:document][:file]
          update_params[:file_path] = save_file(file)
          update_params[:content_type] = file.content_type
          update_params[:file_size] = file.size
        end
        
        if @document.update(update_params)
          render json: document_response(@document)
        else
          render json: { errors: @document.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @document.destroy
        head :no_content
      end
      
      def download
        if File.exist?(@document.file_path)
          send_file @document.file_path, 
                    type: @document.content_type, 
                    disposition: 'attachment',
                    filename: File.basename(@document.file_path)
        else
          render json: { error: 'File not found' }, status: :not_found
        end
      end
      
      private
      
      def set_vault
        @vault = current_user.accessible_vaults.find(params[:vault_id])
      end
      
      def set_document
        @document = @vault.documents.find(params[:id])
      end
      
      def document_params
        params.require(:document).permit(:title, metadata: {})
      end
      
      def apply_search_filters(documents)
        documents = documents.search_by_title(params[:search]) if params[:search].present?
        documents = documents.full_text_search(params[:q]) if params[:q].present?
        documents = documents.by_category(params[:category]) if params[:category].present?
        documents = documents.by_tag(params[:tag]) if params[:tag].present?
        documents = documents.by_content_type(params[:content_type]) if params[:content_type].present?
        documents
      end
      
      def save_file(file)
        dir = Rails.root.join('storage', 'documents', current_user.id.to_s, @vault.id.to_s)
        FileUtils.mkdir_p(dir)
        
        filename = "#{SecureRandom.uuid}_#{file.original_filename}"
        filepath = dir.join(filename)
        
        File.open(filepath, 'wb') do |f|
          f.write(file.read)
        end
        
        filepath.to_s
      end
      
      def document_response(document)
        {
          id: document.id,
          title: document.title,
          vault_id: document.vault_id,
          file_url: document.file_url,
          content_type: document.content_type,
          metadata: document.metadata,
          is_owner: document.owner?(current_user),
          access_level: owner_key? ? 'full' : 'read_only',
          created_at: document.created_at,
          updated_at: document.updated_at
        }
      end
    end
  end
end