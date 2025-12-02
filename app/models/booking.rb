class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :class_booking

  # This ensures the email is queued ONLY after the database transaction is committed.
  after_create_commit :send_confirmation_email

  # Validation to enforce uniqueness
  validates :user_id, uniqueness: { scope: :class_booking_id, message: "has already booked this class." }

  # CRITICAL: Custom validation to prevent booking if full
  validate :check_class_capacity, on: :create

  private

  def check_class_capacity
    # Check the actual class object to ensure capacity is not exceeded
    if class_booking.full?
      errors.add(:base, "This class is full. Please try another time.")
    end
  end
  
   def send_confirmation_email
    # Use the robust 'with' pattern, passing the booking object itself.
    BookingMailer.with(booking: self).confirmation_email.deliver_later
  end
end