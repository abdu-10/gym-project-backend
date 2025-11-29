module Admin
  class DashboardController < Admin::ApplicationController
    def index
      # Core Stats
      @total_members = User.where.not(role: "admin").count
      @active_members = User.where.not(role: "admin").select { |u| u.active_membership? }.count
      @expired_members = @total_members - @active_members
      
      # New signups (last 30 days)
      @new_signups_30_days = User.where.not(role: "admin")
                                 .where("created_at >= ?", 30.days.ago)
                                 .count
      
      # New signups (last 7 days)
      @new_signups_7_days = User.where.not(role: "admin")
                                .where("created_at >= ?", 7.days.ago)
                                .count
      
      # Members by plan
      @members_by_plan = Membership.joins(:plan)
                                   .group("plans.name")
                                   .count
      
      # Recent signups (last 10)
      @recent_signups = User.where.not(role: "admin")
                            .order(created_at: :desc)
                            .limit(10)
                            .includes(:membership, :plan)
      
      # Expiring soon (next 7 days) - members whose membership will expire
      @expiring_soon = User.where.not(role: "admin")
                           .includes(:membership, :plan)
                           .select { |u| u.active_membership? && membership_expires_within?(u, 7.days) }
                           .first(5)
      
      # Today's stats
      @signups_today = User.where.not(role: "admin")
                           .where("created_at >= ?", Time.current.beginning_of_day)
                           .count
    end
    
    private
    
    def membership_expires_within?(user, duration)
      return false unless user.membership.present? && user.plan.present?
      
      plan_duration = case user.plan.name
                      when 'Basic' then 1.month
                      when 'Quarterly' then 3.months
                      when 'Premium' then 6.months
                      when 'Elite' then 1.year
                      else 0.seconds
                      end
      
      expiration_date = user.created_at + plan_duration
      expiration_date <= Time.current + duration
    end
  end
end
