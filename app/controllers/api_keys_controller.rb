class ApiKeysController < ApplicationController

  def index
    render json: current_user.api_keys.order(created_at: :desc).as_json(only: %i[id last_seen created-at])
  end

  def create
    key = ApiKey.generate!(current_user)
    render json: { api_key: key }, status: :created
  end

  def destroy
    key = current_user.api_keys.find(params[:id])
    key.revoke!

    head :no_content
end