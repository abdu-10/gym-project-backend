# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_admin
    layout "admin"
    
    # Make current_user available to views
    helper_method :current_user

    def authenticate_admin
      unless current_user&.role == "admin"
        redirect_to admin_login_path, alert: "Please log in as an administrator to continue."
      end
    end
    
    # Inherit from main ApplicationController helpers
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    def records_per_page
      params[:per_page] || 25
    end
  end
end
