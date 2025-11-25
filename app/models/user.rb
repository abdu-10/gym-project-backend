class User < ApplicationRecord

    has_secure_password

    has_one :membership

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true

    has_one :plan, through: :membership

    # --- NEW: THE "LEGIT" LOGIC ---
  # This calculates if the user is allowed in the gym RIGHT NOW.
  def active_membership?
    return false unless membership.present?
    return false unless plan.present?

    # 1. Determine how long the plan lasts
    duration = case plan.name
               when 'Basic' then 1.month
               when 'Quarterly' then 3.months
               when 'Premium' then 6.months
               when 'Elite' then 1.year
               else 0.seconds
               end

    # 2. Calculate the expiration date based on when they joined
    #    (We use the User created_at date as the join date)
    expiration_date = created_at + duration

    # 3. Check if today is BEFORE the expiration date
    Time.current < expiration_date
  end
end
