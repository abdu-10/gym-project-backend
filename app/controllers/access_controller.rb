class AccessController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :require_admin

  def verify
    # The scanner sends the QR content
    token = params[:user_id]
    
    if token.blank?
      return render json: { status: "error", message: "No QR data received" }, status: :bad_request
    end
    # 2. Find User by QR Token
    # We ONLY look up by the secure random token.
    # We removed the fallback that checked for ID.
    # Now, knowing "User ID 13" is useless for access.
    user = User.find_by(qr_token: token)

    if user.nil?
      return render json: { status: "denied", error: "Invalid QR Code" }, status: :not_found
    end

    # 3. Check Membership & Log Attendance
    if user.active_membership?
      
      Attendance.create!(user: user, checked_in_at: Time.current)

      render json: { 
        status: "allowed",
        message: "Access Granted",
        user: {
          name: user.name,
          email: user.email,
          photo: user.profile_photo.attached? ? url_for(user.profile_photo) : nil,
          plan: user.plan&.name,
          visits: user.attendances.count
        }
      }, status: :ok

    else
      render json: { 
        status: "denied",
        error: "Membership Expired / Inactive",
        user: {
          name: user.name,
          plan: user.plan&.name,
          photo: user.profile_photo.attached? ? url_for(user.profile_photo) : nil
        }
      }, status: :ok
    end
  end

  private

  def require_admin
    unless current_user&.role == "admin"
      render json: { error: "Unauthorized Staff Access" }, status: :unauthorized
    end
  end
end