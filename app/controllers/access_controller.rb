class AccessController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /access/verify
  def verify
    # 1. Find the user by the ID coming from the QR Code
    user = User.find_by(id: params[:user_id])

    if user.nil?
      render json: { status: "error", message: "User not found" }, status: :not_found
      return
    end

    # 2. Ask the User model: "Are you active?"
    if user.active_membership?
      # --- ACCESS GRANTED ---
      render json: {
        status: "granted",
        user: {
          name: user.name,
          plan: user.plan.name,
          photo: "https://ui-avatars.com/api/?name=#{user.name}&background=DC2626&color=fff&size=128" # Auto-generate avatar
        }
      }
    else
      # --- ACCESS DENIED ---
      render json: {
        status: "denied",
        user: {
          name: user.name,
          plan: user.plan&.name
        },
        message: "Membership Expired"
      }, status: :ok # We return 200 OK because the *check* worked, even if the result is bad.
    end
  end
end