class TrainerBookingsController < ApplicationController

  # Require user to be logged in
  before_action :require_login

  def create
    # Use current_user (must be logged in)
    user = current_user

    # Build booking and associate with current_user
    @booking = TrainerBooking.new(trainer_booking_params)
    @booking.user = user

    # Convert preferred_time from 12-hour format (e.g., "4:00 PM") to 24-hour format (e.g., "16:00")
    if @booking.preferred_time.present?
      @booking.preferred_time = convert_to_24hour_time(@booking.preferred_time)
    end

    if @booking.save
      # Send confirmation email to user asynchronously
      TrainerBookingMailer.with(booking: @booking).confirmation_email.deliver_later

      # Send notification email to trainer asynchronously
      trainer = Trainer.find_by(id: @booking.trainer_id)
      if trainer.present?
        TrainerBookingMailer.with(booking: @booking, trainer: trainer).trainer_notification_email.deliver_later
      else
        Rails.logger.warn "TrainerBookingsController: Trainer not found for booking (trainer_id: #{@booking.trainer_id})"
      end

      render json: {
        message: "Booking created successfully!",
        booking: @booking
      }, status: :created
    else
      render json: {
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  # Strong parameters - only permit trainer details, not user details (they come from current_user)
  def trainer_booking_params
    params.require(:trainer_booking).permit(
      :trainer_id,
      :trainer_name,
      :user_phone,
      :preferred_date,
      :preferred_time,
      :goals_message
    )
  end

  # Convert 12-hour time format to 24-hour format
  # e.g., "4:00 PM" -> "16:00", "9:30 AM" -> "09:30"
  # Handles both string and Time objects
  def convert_to_24hour_time(time_value)
    return time_value if time_value.blank?

    # If it's already a Time object, format it as HH:MM
    if time_value.is_a?(Time)
      return time_value.strftime('%H:%M')
    end

    # Convert to string for further processing
    time_string = time_value.to_s

    # If it's already in 24-hour format (HH:MM), return as is
    return time_string if time_string.match?(/^\d{2}:\d{2}$/)

    # Parse 12-hour format (e.g., "4:00 PM", "6:00 AM")
    begin
      time_obj = Time.parse(time_string)
      time_obj.strftime('%H:%M')
    rescue StandardError
      time_string
    end
  end

  # Ensure user is logged in
  def require_login
    unless current_user
      render json: { error: "You must be logged in to book a session." }, status: :unauthorized
    end
  end
end
