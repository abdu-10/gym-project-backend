class TrainerBooking < ApplicationRecord
  belongs_to :user
  belongs_to :trainer, class_name: 'Trainer', foreign_key: 'trainer_id', optional: true

  # Scopes for filtering bookings
  scope :for_trainer_user, ->(trainer_user_id) {
    joins(:trainer).where(trainers: { user_id: trainer_user_id })
  }

  # Default available time slots (hourly intervals from 6 AM to 9 PM)
  DEFAULT_TIME_SLOTS = [
    "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00",
    "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00"
  ].freeze

  # Validations
  validate :no_trainer_double_booking

  # Custom validation to prevent trainer double booking
  # A trainer cannot be booked for the same date and time
  def no_trainer_double_booking
    return if trainer_id.blank? || preferred_date.blank? || preferred_time.blank?

    conflicting_booking = TrainerBooking
      .where(trainer_id: trainer_id)
      .where(preferred_date: preferred_date)
      .where(preferred_time: preferred_time)
      .where.not(id: id) # Exclude current booking when updating
      .where.not(status: 'cancelled') # Treat NULL or any non-cancelled status as active
      .exists?

    if conflicting_booking
      errors.add(:base, "This trainer is already booked for #{preferred_date} at #{preferred_time.strftime('%I:%M %p')}. Please choose a different time.")
    end
  end

  # Class method to get available time slots for a trainer on a specific date
  def self.available_slots_for_trainer(trainer_id, date)
    # Parse the date
    parsed_date = Date.parse(date)

    # Find all booked times for this trainer on this date (exclude cancelled)
    # Include status = nil (treat as active), pending, confirmed, and any other non-cancelled status
    booked_times = TrainerBooking
      .where(trainer_id: trainer_id)
      .where(preferred_date: parsed_date)
      .where('status IS NULL OR status != ?', 'cancelled')
      .pluck(:preferred_time)
      .map do |time|
        # preferred_time may be a Time object or a plain string; normalize to HH:MM
        if time.respond_to?(:strftime)
          time.strftime('%H:%M')
        else
          # Normalize strings like "4:00 PM" or "16:00" to HH:MM where possible
          begin
            Time.parse(time.to_s).strftime('%H:%M')
          rescue StandardError
            time.to_s
          end
        end
      end
      .compact
      .uniq

    # Return all slots that are NOT booked
    available_slots = DEFAULT_TIME_SLOTS.reject { |slot| booked_times.include?(slot) }

    available_slots
  end
end
