module Admin
  class SessionsController < ApplicationController
    layout "admin"

    # Skip admin auth for login pages (otherwise we'd have infinite redirect)
    skip_before_action :authenticate_admin, only: [ :new, :create ], if: -> { self.class.method_defined?(:authenticate_admin) }

    def new
      # If already logged in as admin, redirect to dashboard
      if current_user&.role == "admin"
        redirect_to admin_root_path
      end
    end

    def create
      user = User.find_by(email: params[:email]&.downcase&.strip)

      if user&.authenticate(params[:password])
        if user.role == "admin"
          log_in(user)
          redirect_to admin_root_path, notice: "Welcome back, #{user.name}!"
        else
          flash.now[:alert] = "Access denied. Admin privileges required."
          render :new, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      log_out
      redirect_to admin_login_path, notice: "You have been logged out."
    end
  end
end
