class ApplicationController < ActionController::Base
  # This allows us to use Sessions/Cookies but skips the browser security check
  # since we are using React.
  skip_before_action :verify_authenticity_token

  # Helper method to log in a user
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
end