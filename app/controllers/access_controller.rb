class AccessController < ApplicationController
 
  # We add `raise: false` so it doesn't crash if your app is in API mode
  skip_before_action :verify_authenticity_token, raise: false

  # POST /access/verify
  def verify
    user = User.find_by(id: params[:user_id])

    if user.nil?
      render json: { status: "error", message: "User not found" }, status: :not_found
      return
    end

    # --- STRICT SECURITY: REAL PHOTO ONLY ---
    # We removed the avatar generator. 
    # If they have a photo, we send it. If not, we send nil.
    # The Security Guard will see "No Pic" on the scanner if this is nil.
    photo_url = user.profile_photo.attached? ? url_for(user.profile_photo) : nil

    # --- DEBUGGING (Check your Server Terminal when scanning) ---
    puts "------------------------------------------------"
    puts "VERIFYING USER: #{user.name} (ID: #{user.id})"
    
    if user.membership.nil?
      puts "FAILURE REASON: User has NO membership record."
    elsif !user.active_membership?
      puts "FAILURE REASON: Membership exists but active_membership? returned false."
      puts "End Date: #{user.membership.end_date}"
    else
      puts "SUCCESS: Membership is active."
    end
    puts "------------------------------------------------"

    # --- CHECK ACCESS ---
    if user.active_membership?
      render json: {
        status: "granted",
        user: {
          name: user.name,
          plan: user.membership&.plan&.name || "Member",
          photo: photo_url 
        }
      }
    else
      render json: {
        status: "denied",
        message: "Membership Expired / Inactive",
        user: {
          name: user.name,
          plan: user.membership&.plan&.name || "No Plan",
          photo: photo_url # We still send the photo so the guard can identify user
        }
      }, status: :ok
    end
  end
end