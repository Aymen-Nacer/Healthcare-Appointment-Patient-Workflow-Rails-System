class ApplicationController < ActionController::API
  private

  def authenticate!
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.blank?
      render json: { message: "Authorization token required" }, status: :unauthorized
      return false
    end

    payload = JwtService.decode(token)
    if payload.nil?
      render json: { message: "Invalid or expired token" }, status: :unauthorized
      return false
    end

    @current_user_id = payload["userId"]
    @current_user_role = payload["role"]
    true
  end

  def require_role!(*roles)
    unless roles.map(&:to_s).include?(@current_user_role)
      render json: { message: "Forbidden" }, status: :forbidden
      return false
    end
    true
  end

  def current_user_id
    @current_user_id
  end

  def current_user_role
    @current_user_role
  end
end
