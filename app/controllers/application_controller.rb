class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :authenticate_request!
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  
  private
  
  def authenticate_request!
    authenticate_or_request_with_http_token do |token, options|
      # First, try to find as owner key
      user = User.find_by(owner_api_key: token)
      
      if user
        @current_user = user
        @is_owner_key = true
        @shared_key = nil
      else
        shared_key = SharedApiKey.active.find_by(key: token)
        
        if shared_key
          @current_user = shared_key.user
          @is_owner_key = false
          @shared_key = shared_key
          
          shared_key.touch_last_used!
        end
      end
      
      @current_user.present?
    end
  end
  
  attr_reader :current_user
  
  def owner_key?
    @is_owner_key
  end
  
  def shared_key?
    !@is_owner_key
  end
  
  def require_owner_key!
    return true if owner_key?

    render json: { 
      error: 'This action requires an owner API key. You are using a shared key(read-only).' 
    }, status: :forbidden
    false
  end
  
  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  def unprocessable_entity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
  
  def forbidden
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end