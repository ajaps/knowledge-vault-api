module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
    attr_reader :current_user, :current_api_key
  end

  private

  def authenticate!
    token = request.headers["X-API-Key"].presence || request.authorization&.delete_prefix("Bearer ")
    @current_api_key = ApiKey.find(token: token)
    head :unauthorized and return unless @current_api_key

    @current_api_key.touch(:last_seen)
    @current_user = @current_api_key.user
  end
end