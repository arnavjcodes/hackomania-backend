class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.

  skip_before_action :verify_authenticity_token

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    decoded_token = JsonWebToken.decode(token)

    if decoded_token && (user = User.find_by(id: decoded_token[:user_id]))
      @current_user = user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
  
end
