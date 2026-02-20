class TrainerBookingsController < ApplicationController

  # Require user to be logged in
  before_action :require_login

  # GET /trainer_bookings?user_id={id}  - Get bookings for a client
  # GET /trainer_bookings?trainer_user_id={id} - Get bookings for a trainer (their sessions)
  # Fetch all bookings with trainer details
  def index
    # Support both user_id (for clients) and trainer_user_id (for trainers)
    if params[:trainer_user_id]
      # Trainer dashboard - show all bookings for this trainer's sessions
      trainer_user_id = params[:trainer_user_id]
      
      unless trainer_user_id
        return render json: { error: "trainer_user_id parameter is required" }, status: :bad_request
      end
      
      bookings = TrainerBooking.for_trainer_user(trainer_user_id).includes(:trainer, :user).order(preferred_date: :asc, preferred_time: :asc)
      
      bookings_data = bookings.map do |booking|
        {
          id: booking.id,
          user_name: booking.user&.name,
          user_email: booking.user&.email,
          trainer_name: booking.trainer&.name || booking.trainer_name,
          trainer_email: booking.trainer&.email,
          trainer_phone: booking.trainer&.phone,
          trainer_image: booking.trainer&.image,
          trainer_role: booking.trainer&.role,
          preferred_date: booking.preferred_date,
          preferred_time: booking.preferred_time&.strftime('%H:%M'),
          goals_message: booking.goals_message,
          status: booking.status || 'pending',
          created_at: booking.created_at,
          updated_at: booking.updated_at
        }
      end
    else
      # Client dashboard - show bookings for this user
      user_id = params[:user_id] || current_user&.id

      unless user_id
        return render json: { error: "user_id parameter is required" }, status: :bad_request
      end

      bookings = TrainerBooking.includes(:trainer).where(user_id: user_id).order(created_at: :desc)

      bookings_data = bookings.map do |booking|
        {
          id: booking.id,
          trainer_name: booking.trainer&.name || booking.trainer_name,
          trainer_email: booking.trainer&.email,
          trainer_phone: booking.trainer&.phone,
          trainer_image: booking.trainer&.image,
          trainer_role: booking.trainer&.role,
          preferred_date: booking.preferred_date,
          preferred_time: booking.preferred_time&.strftime('%H:%M'),
          goals_message: booking.goals_message,
          status: booking.status || 'pending',
          created_at: booking.created_at,
          updated_at: booking.updated_at
        }
      end
    end

    render json: { trainer_bookings: bookings_data }, status: :ok
  end

  # PATCH /trainer_bookings/:id
  # Cancel a booking by setting status to 'cancelled'
  def update
    booking = TrainerBooking.find_by(id: params[:id])

    unless booking
      return render json: { error: "Booking not found" }, status: :not_found
    end

    status = params[:status] || params.dig(:trainer_booking, :status)

    if status.blank?
      return render json: { error: "status parameter is required" }, status: :bad_request
    end

    is_booking_owner = booking.user_id == current_user&.id
    is_trainer_owner = booking.trainer&.user_id == current_user&.id

    case status
    when 'cancelled'
      unless is_booking_owner
        return render json: { error: "Unauthorized to modify this booking" }, status: :forbidden
      end
    when 'confirmed', 'accepted', 'rejected'
      unless is_trainer_owner
        return render json: { error: "Unauthorized to modify this booking" }, status: :forbidden
      end
    else
      return render json: { error: "Unsupported status" }, status: :bad_request
    end

    booking.status = (status == 'accepted' ? 'confirmed' : status)

    if booking.save
      if status == 'cancelled'
        # Send cancellation notification to trainer asynchronously
        trainer = Trainer.find_by(id: booking.trainer_id)
        if trainer.present?
          TrainerBookingMailer.with(booking: booking, trainer: trainer).trainer_cancellation_email.deliver_later
        else
          Rails.logger.warn "TrainerBookingsController: Trainer not found for cancellation (trainer_id: #{booking.trainer_id})"
        end
      elsif booking.status == 'confirmed'
        trainer = booking.trainer
        if trainer.present?
          TrainerBookingMailer.with(booking: booking, trainer: trainer).booking_confirmed_email.deliver_later
        else
          Rails.logger.warn "TrainerBookingsController: Trainer not found for confirmation (trainer_id: #{booking.trainer_id})"
        end
      elsif booking.status == 'rejected'
        trainer = booking.trainer
        if trainer.present?
          TrainerBookingMailer.with(booking: booking, trainer: trainer).booking_rejected_email.deliver_later
        else
          Rails.logger.warn "TrainerBookingsController: Trainer not found for rejection (trainer_id: #{booking.trainer_id})"
        end
      end

      render json: {
        message: "Booking updated successfully",
        booking: {
          id: booking.id,
          status: booking.status,
          updated_at: booking.updated_at
        }
      }, status: :ok
    else
      render json: { errors: booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

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
