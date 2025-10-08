class Api::V1::DocumentsController < ApplicationController
# before_action :require_auth!
  before_action :set_vault, only: %i[index create]

  def index
    authorize @vault, :show?
    docs = @vault.documents.search(params[:q]).order(created_at: :desc)
    render json: { items: docs }
  end

  def create
    authorize @vault, :update?
    doc = @vault.documents.create!(document_params)
    render json: doc, status: :created
  end

  def show
    doc = Document.find(params[:id])
    authorize doc

    render json: doc
  end

  def update
    doc = Document.find(params[:id])
    authorize doc
    doc.update!(document_params)

    render json: doc
  end

  def destroy
    doc = Document.find(params[:id])
    authorize doc
    doc.destroy!

    head :no_content
  end

  private

  def set_vault
    @vault = Vault.find(params[:vault_id])
  end

  def document_params
    params.require(:document).permit(:title, :body, :tags)
  end
end