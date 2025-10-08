class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    head :unauthorized and return unless users&.authenticate(params[:password])

    render json: {
      jwt: user.issue_jwt
    }
end