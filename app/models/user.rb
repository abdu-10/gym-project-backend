class User < ApplicationRecord

    has_secure_password

    has_one :membership

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true

    has_one :plan, through: :membership

    has_one_attached :profile_photo

    has_secure_token :qr_token 

     has_many :attendances, dependent: :destroy 

    has_many :payments, dependent: :destroy

    # Add this line to link users to their trainer booking history
    has_many :trainer_bookings, dependent: :destroy

    # New booking associations
  has_many :bookings, dependent: :destroy
  has_many :booked_classes, through: :bookings, source: :class_booking

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
