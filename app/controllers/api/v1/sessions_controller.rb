class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate!
  
  def create
    user = User.find_by(email: params[:email])
    head :unauthorized and return unless user&.authenticate(params[:password])

    render json: {
      jwt: user.issue_jwt
    }
  end
end