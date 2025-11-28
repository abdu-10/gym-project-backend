class SessionsController < ApplicationController
  # skip_before_action :verify_authenticity_token # Not needed if using proper CORS/Cookies

  # POST /login
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id 
      
      # --- IMPORTANT: Get the role ---
      user_role = user.role || 'member' 
      plan_name = user.membership&.plan&.name || "No Plan"
      
      # Strict Photo URL
      photo_url = user.profile_photo.attached? ? url_for(user.profile_photo) : nil

      render json: {
        message: "Logged in successfully!",
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user_role, # <--- SENDING ROLE HERE
          plan: plan_name,
          joined_at: user.created_at,
          photo_url: photo_url
        }
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # GET /me
  # This runs when you refresh the page
  def me
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      
      if user
        plan_name = user.membership&.plan&.name || "No Plan"
        user_role = user.role || 'member' # <--- GETTING ROLE HERE TOO
        photo_url = user.profile_photo.attached? ? url_for(user.profile_photo) : nil

        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user_role, # <--- SENDING ROLE HERE
            plan: plan_name,
            joined_at: user.created_at,
            photo_url: photo_url
          }
        }, status: :ok
      else
        session[:user_id] = nil
        render json: { error: "Not logged in" }, status: :unauthorized
      end
    else
      render json: { error: "Not logged in" }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    session[:user_id] = nil
    render json: { message: "Logged out" }, status: :ok
  end
end