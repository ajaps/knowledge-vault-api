class ApplicationController < ActionController::API

  private

  def current_user
    @current_user ||= authenticate_with_api_key || authenticate_with_jwt
  end

  def authenticate_with_api_key
    raw = request.headers["X-API-Key"].strip
    return if raw.blank?

    ApiKey.find_user_by_token(raw)
  end

  def authenticate_with_jwt
    header = request.headers["Authorization"]
    token = header.split(" ")[-1]

    return if token.blank?

    begin
      payload, = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
      User.find_by(id: payload["sub"])
    rescue JWT::DecodeError
      nil
    end
  end
end
