class MembersDashboardController < ApplicationController
  before_action :require_user

  def show
    user = current_user
    
    # Debugging: This prints to your terminal so you can verify data exists
    puts "--- DASHBOARD DEBUG ---"
    puts "User: #{user.id} (#{user.name})"
    puts "Payments Found: #{user.payments.count}"
    
    # 1. Gather Attendance Stats
    attendance_count = user.attendances&.count || 0
    
    # 2. Gather Payment History (BULLETPROOFED)
    # We add safeguards (|| 0) to prevent crashes if data is missing
    payment_history = user.payments.order(created_at: :desc).map do |p|
      {
        id: p.id,
        date: p.created_at.strftime("%b %d, %Y"),
        amount: "$#{((p.amount_cents || 0) / 100.0).round(2)}", 
        method: p.payment_method&.capitalize || "Card",
        status: p.status || "pending",
        description: p.description || "Membership Payment"
      }
    end

    # 3. Gather Recent Activity
    recent_activity = user.attendances&.order(created_at: :desc)&.limit(5)&.map do |a| 
      { 
        date: a.created_at.strftime("%b %d"), 
        time: a.created_at.strftime("%I:%M %p") 
      }
    end

    # 4. Return Data
    render json: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        profile_photo: user.profile_photo.attached? ? url_for(user.profile_photo) : nil,
        qr_code_value: user.qr_token # Secure QR Token
      },
      membership: {
        plan: user.plan&.name || "No Plan",
        status: user.active_membership? ? "active" : "expired",
        expires_at: calculate_expiry(user),
        days_left: calculate_days_left(user)
      },
      stats: {
        total_visits: attendance_count,
        streak: calculate_streak(user)
      },
      billing_history: payment_history,
      recent_activity: recent_activity
    }
  end

  private

  def require_user
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def calculate_expiry(user)
    return nil unless user.membership && user.plan
    
    duration = case user.plan.name
               when "Basic" then 1.month
               when "Quarterly" then 3.months
               when "Premium" then 6.months
               when "Elite" then 1.year
               else 0.seconds
               end
    
    (user.created_at + duration).strftime("%b %d, %Y")
  end

  def calculate_days_left(user)
    return 0 unless user.membership && user.plan

    duration = case user.plan.name
               when "Basic" then 1.month
               when "Quarterly" then 3.months
               when "Premium" then 6.months
               when "Elite" then 1.year
               else 0.seconds
               end

    expiration_date = user.created_at + duration
    days = ((expiration_date - Time.current) / 1.day).round
    
    days > 0 ? days : 0
  end

  def calculate_streak(user)
    return 0 unless user.attendances.any?
    user.attendances.where('created_at >= ?', 7.days.ago).count
  end
end