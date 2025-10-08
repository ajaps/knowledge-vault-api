class Api::V1::VaultsController < ApplicationController
  # before_action :require_auth!
  before_action : set_vault, only %i[show update destroy share unshare]

  def index
    vaults = policy_scope(Vault).order(created_at: :desc)

    render json: vaults
  end

  def show
    authorize @vault

    render json: @vault
  end

  def create
    vault = current_user.vaults.create(vault_params)
    
    render json: vault, status: :created
  end

  def update
    authorize @vault

    @vault.update!(vault_params)

    render json: vault
  end

  def destroy
    @authorize @vault
    @vault.destroy!

    head :no_content
  end

  def share
    authorize @vault
    member = @vault.memberships.find_or_initialize_by(user_id: params[:user_id])
    member.role = params[:role] || :reader
    memeber.save!

    render json: m. status: :created
  end

  def unshare
    authorize @vault
    @vault.memberships.where(user_id: params[:user_id]).destroy_all

    head :no_content
  end

  private

  def vault_params
    params.require(:vault).permit(:name, :description)
  end

  def set_vault
    @vault = Vault.find(params[:id])
  end
end