class AdminStatsController < ApplicationController
  before_action :require_admin

  def show
    # 1. SCOPE: Standard members only (Role is member OR nil)
    standard_members = User.where("role = ? OR role IS NULL", "member")
                           .where.not(role: "admin")

    total_members = standard_members.count

    # 2. ACTIVE MEMBERS & REVENUE
    # Pre-fetch associations to avoid N+1 queries
    # We use .select to filter in memory because active_membership? is a model method
    active_users = standard_members.includes(:membership, :plan).select(&:active_membership?)
    
    active_members_count = active_users.count
    
    # FIX: Calculate Revenue using the active_users array we just built
    # Use &. to safely access plan in case of weird data
    monthly_revenue = active_users.sum { |u| u.plan&.price_in_cents.to_i } / 100.0

    expired_members = total_members - active_members_count

    # 3. TIME BASED STATS
    new_signups_30_days = standard_members.where("created_at >= ?", 30.days.ago).count
    new_signups_7_days = standard_members.where("created_at >= ?", 7.days.ago).count
    signups_today = standard_members.where("created_at >= ?", Time.current.beginning_of_day).count

    # 4. CHART DATA (Last 6 Months)
    # FIX: This logic MUST be inside the 'def show', not outside!
    growth_history = 6.times.map do |i|
      date = i.months.ago
      {
        name: date.strftime("%b"),
        signups: standard_members.where(created_at: date.all_month).count
      }
    end.reverse

    # 5. BREAKDOWNS
    members_by_plan = Membership.joins(:user, :plan)
                                .where("users.role = ? OR users.role IS NULL", "member")
                                .where.not("users.role = ?", "admin")
                                .group("plans.name")
                                .count

    recent_signups = standard_members.order(created_at: :desc)
                                     .limit(10)
                                     .includes(:membership, :plan)
                                     .map { |u| user_summary(u) }

    expiring_soon = standard_members.includes(:membership, :plan)
                                    .select { |u| u.active_membership? && membership_expires_within?(u, 7.days) }
                                    .first(5)
                                    .map { |u| user_summary(u) }

    # FIX: Add the missing keys (monthly_revenue, growth_history) to the JSON response
    render json: {
      total_members: total_members,
      active_members: active_members_count,
      expired_members: expired_members,
      monthly_revenue: monthly_revenue,     # <--- WAS MISSING
      growth_history: growth_history,       # <--- WAS MISSING
      new_signups_7_days: new_signups_7_days,
      new_signups_30_days: new_signups_30_days,
      signups_today: signups_today,
      members_by_plan: members_by_plan,
      recent_signups: recent_signups,
      expiring_soon: expiring_soon
    }
  end

  private

  def require_admin
    unless current_user&.role == "admin"
      render json: { error: "Forbidden - Admin access required" }, status: :forbidden
    end
  end

  def user_summary(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      plan: user.plan&.name || "No Plan",
      active: user.active_membership?,
      joined_at: user.created_at.strftime("%b %d, %Y")
    }
  end

  def membership_expires_within?(user, duration)
    return false unless user.membership.present? && user.plan.present?

    plan_duration = case user.plan.name
                    when "Basic" then 1.month
                    when "Quarterly" then 3.months
                    when "Premium" then 6.months
                    when "Elite" then 1.year
                    else 0.seconds
                    end

    expiration_date = user.created_at + plan_duration
    expiration_date <= Time.current + duration
  end
end