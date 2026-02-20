class TrainerBookingMailer < ApplicationMailer
  default from: 'notifications@fitelitegym.com' # Make sure this is your verified SMTP sender

  # Sends a confirmation email for a trainer booking
  # Usage: TrainerBookingMailer.with(booking: booking_data).confirmation_email.deliver_later
  def confirmation_email
    raw = params[:booking]

    # Normalize booking parameter: accept Hash-like, ActiveRecord, or plain object
    @booking = if raw.respond_to?(:symbolize_keys)
                 raw.symbolize_keys
               elsif raw.respond_to?(:attributes)
                 raw.attributes.symbolize_keys
               else
                 {}
               end

    # Extract user data from association if available
    if raw.respond_to?(:user) && raw.user.present?
      @booking[:user_email] ||= raw.user.email
      @booking[:user_name] ||= raw.user.name
    end

    # Format preferred_time if it's a Time object
    if @booking[:preferred_time].present? && @booking[:preferred_time].is_a?(Time)
      @booking[:preferred_time] = @booking[:preferred_time].strftime('%H:%M')
    end

    # If still missing email, log and exit gracefully
    unless @booking[:user_email].present?
      Rails.logger.warn "TrainerBookingMailer: No user_email provided, skipping email. booking=#{raw.inspect}" 
      return
    end

    Rails.logger.info "Preparing trainer booking confirmation email for #{@booking[:user_email]} (Trainer: #{@booking[:trainer_name]})"

    mail(
      to: @booking[:user_email],
      subject: "Trainer Booking Confirmation - FitElite"
    )
  rescue StandardError => e
    # Catch mailer errors so they don't break your controller response
    Rails.logger.error "TrainerBookingMailer error: #{e.message}"
  end

  # Optional: cancellation email
  # Usage: TrainerBookingMailer.with(booking: booking_data).cancellation_email.deliver_later
  def cancellation_email
    @booking = params[:booking]&.symbolize_keys

    unless @booking&.dig(:user_email).present?
      Rails.logger.warn "TrainerBookingMailer: No user_email provided for cancellation, skipping email."
      return
    end

    Rails.logger.info "Preparing trainer booking cancellation email for #{@booking[:user_email]}"

    mail(
      to: @booking[:user_email],
      subject: "Trainer Booking Cancellation"
    )
  rescue StandardError => e
    Rails.logger.error "TrainerBookingMailer cancellation error: #{e.message}"
  end

  # Sends a notification email to trainer about a new booking
  # Usage: TrainerBookingMailer.with(booking: booking_obj, trainer: trainer_obj).trainer_notification_email.deliver_later
  def trainer_notification_email
    raw_booking = params[:booking]
    trainer_obj = params[:trainer]

    # Normalize booking data
    @booking = if raw_booking.respond_to?(:symbolize_keys)
                 raw_booking.symbolize_keys
               elsif raw_booking.respond_to?(:attributes)
                 raw_booking.attributes.symbolize_keys
               else
                 {}
               end

    # Extract user data from association if available
    if raw_booking.respond_to?(:user) && raw_booking.user.present?
      @booking[:user_name] ||= raw_booking.user.name
      @booking[:user_email] ||= raw_booking.user.email
    end

    # Format preferred_time if it's a Time object
    if @booking[:preferred_time].present? && @booking[:preferred_time].is_a?(Time)
      @booking[:preferred_time] = @booking[:preferred_time].strftime('%H:%M')
    end

    # Get trainer information
    @trainer = if trainer_obj.respond_to?(:email)
                 trainer_obj
               else
                 nil
               end

    # Skip if trainer email is missing
    unless @trainer&.email.present?
      Rails.logger.warn "TrainerBookingMailer: No trainer email provided, skipping trainer notification. booking=#{raw_booking.inspect}"
      return
    end

    Rails.logger.info "Preparing trainer booking notification email for trainer #{@trainer.email} (User: #{@booking[:user_name]})"

    # Extract user name for subject line
    user_name = @booking[:user_name] || "New Client"

    mail(
      to: @trainer.email,
      subject: "New Booking Request from #{user_name}"
    )
  rescue StandardError => e
    Rails.logger.error "TrainerBookingMailer trainer notification error: #{e.message}"
  end

  # Sends a notification email to trainer about a cancelled booking
  # Usage: TrainerBookingMailer.with(booking: booking_obj, trainer: trainer_obj).trainer_cancellation_email.deliver_later
  def trainer_cancellation_email
    raw_booking = params[:booking]
    trainer_obj = params[:trainer]

    # Normalize booking data
    @booking = if raw_booking.respond_to?(:symbolize_keys)
                 raw_booking.symbolize_keys
               elsif raw_booking.respond_to?(:attributes)
                 raw_booking.attributes.symbolize_keys
               else
                 {}
               end

    # Extract user data from association if available
    if raw_booking.respond_to?(:user) && raw_booking.user.present?
      @booking[:user_name] ||= raw_booking.user.name
      @booking[:user_email] ||= raw_booking.user.email
    end

    # Format preferred_time if it's a Time object
    if @booking[:preferred_time].present? && @booking[:preferred_time].is_a?(Time)
      @booking[:preferred_time] = @booking[:preferred_time].strftime('%H:%M')
    end

    # Get trainer information
    @trainer = if trainer_obj.respond_to?(:email)
                 trainer_obj
               else
                 nil
               end

    # Skip if trainer email is missing
    unless @trainer&.email.present?
      Rails.logger.warn "TrainerBookingMailer: No trainer email provided, skipping trainer cancellation. booking=#{raw_booking.inspect}"
      return
    end

    Rails.logger.info "Preparing trainer cancellation notification email for trainer #{@trainer.email} (User: #{@booking[:user_name]})"

    # Extract user name for subject line
    user_name = @booking[:user_name] || "Client"

    mail(
      to: @trainer.email,
      subject: "Booking Cancelled by #{user_name}"
    )
  rescue StandardError => e
    Rails.logger.error "TrainerBookingMailer trainer cancellation error: #{e.message}"
  end

  # Sends a confirmation email to user when trainer accepts the booking
  # Usage: TrainerBookingMailer.with(booking: booking_obj, trainer: trainer_obj).booking_confirmed_email.deliver_later
  def booking_confirmed_email
    raw_booking = params[:booking]
    trainer_obj = params[:trainer]

    @booking = if raw_booking.respond_to?(:symbolize_keys)
                 raw_booking.symbolize_keys
               elsif raw_booking.respond_to?(:attributes)
                 raw_booking.attributes.symbolize_keys
               else
                 {}
               end

    if raw_booking.respond_to?(:user) && raw_booking.user.present?
      @booking[:user_name] ||= raw_booking.user.name
      @booking[:user_email] ||= raw_booking.user.email
    end

    if @booking[:preferred_time].present? && @booking[:preferred_time].is_a?(Time)
      @booking[:preferred_time] = @booking[:preferred_time].strftime('%H:%M')
    end

    @trainer = trainer_obj if trainer_obj.respond_to?(:name)

    unless @booking[:user_email].present?
      Rails.logger.warn "TrainerBookingMailer: No user_email provided for confirmation, skipping email."
      return
    end

    mail(
      to: @booking[:user_email],
      subject: "Booking Confirmed - FitElite"
    )
  rescue StandardError => e
    Rails.logger.error "TrainerBookingMailer booking confirmed error: #{e.message}"
  end

  # Sends a rejection email to user when trainer declines the booking
  # Usage: TrainerBookingMailer.with(booking: booking_obj, trainer: trainer_obj).booking_rejected_email.deliver_later
  def booking_rejected_email
    raw_booking = params[:booking]
    trainer_obj = params[:trainer]

    @booking = if raw_booking.respond_to?(:symbolize_keys)
                 raw_booking.symbolize_keys
               elsif raw_booking.respond_to?(:attributes)
                 raw_booking.attributes.symbolize_keys
               else
                 {}
               end

    if raw_booking.respond_to?(:user) && raw_booking.user.present?
      @booking[:user_name] ||= raw_booking.user.name
      @booking[:user_email] ||= raw_booking.user.email
    end

    if @booking[:preferred_time].present? && @booking[:preferred_time].is_a?(Time)
      @booking[:preferred_time] = @booking[:preferred_time].strftime('%H:%M')
    end

    @trainer = trainer_obj if trainer_obj.respond_to?(:name)

    unless @booking[:user_email].present?
      Rails.logger.warn "TrainerBookingMailer: No user_email provided for rejection, skipping email."
      return
    end

    mail(
      to: @booking[:user_email],
      subject: "Booking Update - FitElite"
    )
  rescue StandardError => e
    Rails.logger.error "TrainerBookingMailer booking rejected error: #{e.message}"
  end
end
