class SessionsController < ApplicationController
  # skip_before_action :verify_authenticity_token # Not needed if we use proper CORS/Cookies

  # POST /login
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      
      # --- SECURITY UPGRADE ---
      # This saves the ID in an encrypted, HttpOnly cookie.
      # The browser handles this. React cannot see it.
      session[:user_id] = user.id 
      # ------------------------

      plan_name = user.membership&.plan&.name || "No Plan"

       # --- NEW: Get Photo URL ---
      photo_url = user.profile_photo.attached? ? url_for(user.profile_photo) : nil

      render json: {
        message: "Logged in successfully!",
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
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
  # This is called when the React app refreshes.
  # It checks the cookie to see if the user is still logged in.
  def me
    # Check the cookie
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      
      if user
        plan_name = user.membership&.plan&.name || "No Plan"
        render json: {
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            plan: plan_name,
            joined_at: user.created_at,
            photo_url: photo_url
          }
        }, status: :ok
      else
        # Cookie existed but user is gone? Clear it.
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