module Api
  module V1
    class VaultsController < ApplicationController
      before_action :set_vault, only: [:show, :update, :destroy]
      before_action :require_owner_key!, only: [:create, :update, :destroy]
      
      def index
        @vaults = current_user.accessible_vaults
        render json: @vaults.map { |v| vault_response(v) }
      end
      
      def show
        render json: vault_response(@vault, include_documents: true)
      end
      
      def create
        @vault = current_user.vaults.new(vault_params)
        
        if @vault.save
          render json: vault_response(@vault), status: :created
        else
          render json: { errors: @vault.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        if @vault.update(vault_params)
          render json: vault_response(@vault)
        else
          render json: { errors: @vault.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @vault.destroy
        head :no_content
      end
      
      private
      
      def set_vault
        @vault = current_user.accessible_vaults.find(params[:id])
      end
      
      def vault_params
        params.require(:vault).permit(:name, :description)
      end
      
      def vault_response(vault, include_documents: false)
        response = {
          id: vault.id,
          name: vault.name,
          description: vault.description,
          owner_id: vault.user_id,
          is_owner: vault.user_id == current_user.id,
          access_level: owner_key? ? 'full' : 'read_only',
          created_at: vault.created_at,
          updated_at: vault.updated_at,
          document_count: vault.documents.count
        }
        
        if include_documents
          response[:documents] = vault.documents.map { |d| document_summary(d) }
        end
        
        response
      end
      
      def document_summary(document)
        {
          id: document.id,
          title: document.title,
          file_url: document.file_url,
          created_at: document.created_at
        }
      end
    end
  end
end