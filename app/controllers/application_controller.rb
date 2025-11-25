class ApplicationController < ActionController::Base

  # We are an API, so we don't use CSRF tokens.
  # We use CORS and HttpOnly cookies for security instead.
  skip_before_action :verify_authenticity_token
  # ----------------

  # Helper method to log in a user (sets the cookie)
  def log_in(user)
    session[:user_id] = user.id
  end

  # Helper method to get the current user
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Helper method to check if logged in
  def logged_in?
    !current_user.nil?
  end
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes


end
