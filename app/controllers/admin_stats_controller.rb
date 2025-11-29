class AdminStatsController < ApplicationController
  before_action :require_admin

  def show
    total_members = User.where.not(role: "admin").count
    active_members = User.where.not(role: "admin").select(&:active_membership?).count
    expired_members = total_members - active_members

    new_signups_30_days = User.where.not(role: "admin")
                              .where("created_at >= ?", 30.days.ago)
                              .count

    new_signups_7_days = User.where.not(role: "admin")
                             .where("created_at >= ?", 7.days.ago)
                             .count

    signups_today = User.where.not(role: "admin")
                        .where("created_at >= ?", Time.current.beginning_of_day)
                        .count

    members_by_plan = Membership.joins(:plan)
                                .group("plans.name")
                                .count

    recent_signups = User.where.not(role: "admin")
                         .order(created_at: :desc)
                         .limit(10)
                         .includes(:membership, :plan)
                         .map { |u| user_summary(u) }

    expiring_soon = User.where.not(role: "admin")
                        .includes(:membership, :plan)
                        .select { |u| u.active_membership? && membership_expires_within?(u, 7.days) }
                        .first(5)
                        .map { |u| user_summary(u) }

    render json: {
      total_members: total_members,
      active_members: active_members,
      expired_members: expired_members,
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
      plan: user.plan&.name,
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
