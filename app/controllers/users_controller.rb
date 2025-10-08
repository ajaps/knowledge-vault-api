class UsersController < ApplicationController
  
  def create
    user = User.create!(user_params)
    key = ApiKey.generate!(user)

    render json: {
      jwt: user.issue_jwt, api_key: key, user: {id: user.id, email: user.email}
    }
  end

  private
  
  def user_params
    params.require(:user).permit(:email, :password)
  end
end