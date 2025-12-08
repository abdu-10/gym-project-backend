class TrainerBookingsController < ApplicationController

  # Require user to be logged in
  before_action :require_login

  def create
    # Use current_user (must be logged in)
    user = current_user

    # Build booking and associate with current_user
    @booking = TrainerBooking.new(trainer_booking_params)
    @booking.user = user

    if @booking.save
      # Send confirmation email asynchronously
      TrainerBookingMailer.with(booking: @booking).confirmation_email.deliver_later

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

  # Strong parameters
  def trainer_booking_params
    params.require(:trainer_booking).permit(
      :trainer_name,
      :user_phone,
      :preferred_date,
      :goals_message
    )
  end

  # Ensure user is logged in
  def require_login
    unless current_user
      render json: { error: "You must be logged in to book a session." }, status: :unauthorized
    end
  end
end
