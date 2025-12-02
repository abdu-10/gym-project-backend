class BookingsController < ApplicationController
  # Runs the inherited require_login method before any action
  before_action :require_login 

  # POST /bookings
  # Params expected: { class_booking_id: 123 }
  def create
    class_booking = ClassBooking.find_by(id: params[:class_booking_id])
    
    unless class_booking
      render json: { error: "Class not found." }, status: :not_found and return
    end
    
    # CRITICAL: Use a transaction with locking to prevent race conditions 
    ActiveRecord::Base.transaction do
      # Lock the class row for exclusive update during the check/create process
      class_booking.lock! 
      
      # Re-check capacity after locking
      if class_booking.full?
        # Raise rollback to abort the transaction if the class is full
        raise ActiveRecord::Rollback, "Booking failed: This class is full." 
      end

      # Create the booking record
      @booking = current_user.bookings.new(class_booking: class_booking)
      
      # NOTE: Confirmation Email is now sent via the after_create_commit callback in Booking model.
      
      if @booking.save
        class_booking.reload # Reload to get the latest counts after the save
        render json: { 
          message: "Class booked successfully!",
          booking: @booking.as_json(only: [:id, :class_booking_id]),
          spots_remaining: class_booking.spots_remaining,
          booked_count: class_booking.booked_count # <--- ADDED booked_count
        }, status: :created
      else
        # Handle double-booking (uniqueness validation) or other model errors
        render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
  rescue ActiveRecord::Rollback => e
    render json: { error: e.message }, status: :conflict 
  rescue => e
    Rails.logger.error "BookingsController Create Error: #{e.message}"
    render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
  end


  # DELETE /bookings/:id (To cancel a booking)
  def destroy
    # Find the booking belonging ONLY to the current user
    @booking = current_user.bookings.find_by(id: params[:id])
    
    unless @booking
      render json: { error: "Booking not found or not owned by you." }, status: :not_found and return
    end

    class_booking = @booking.class_booking
    
    # CRUCIAL FIX: Ensure email is sent before destruction, but wrap in rescue block.
    begin
      user_for_email = @booking.user
      class_for_email = @booking.class_booking
      
      # Use the 'with' pattern for robustness
      BookingMailer.with(user: user_for_email, class_booking: class_for_email).cancellation_email.deliver_now
      Rails.logger.info "Cancellation email successfully queued or sent for booking #{@booking.id}."
    rescue => e
      # Log the email failure but continue the controller action (Cancellation is critical)
      Rails.logger.error "FATAL: Failed to send cancellation email for booking #{@booking.id}: #{e.message}"
      # We intentionally do not raise an error here.
    end

    # This is the original, working database deletion logic.
    if @booking.destroy
      class_booking.reload # Reload to get the latest counts after the destroy
      render json: { 
        message: "Booking cancelled successfully.",
        class_booking_id: class_booking.id, 
        spots_remaining: class_booking.spots_remaining,
        booked_count: class_booking.booked_count # <--- ADDED booked_count
      }, status: :ok
    else
      render json: { error: "Cancellation failed." }, status: :unprocessable_entity
    end
  end
  def require_login
    unless logged_in?
      render json: { error: "You must be logged in to access this resource." }, status: :unauthorized
    end
  end
  
end