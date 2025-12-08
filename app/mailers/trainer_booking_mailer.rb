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

    # If user_email not present in the normalized payload, try association on model
    if @booking[:user_email].blank? && raw.respond_to?(:user) && raw.user.respond_to?(:email)
      @booking[:user_email] = raw.user.email
    end

    # If still missing, log and exit gracefully
    unless @booking[:user_email].present?
      Rails.logger.warn "TrainerBookingMailer: No user_email provided, skipping email. booking=#{raw.inspect}" 
      return
    end

    Rails.logger.info "Preparing trainer booking confirmation email for #{@booking[:user_email]} (Trainer: #{@booking[:trainer_name]})"

    mail(
      to: @booking[:user_email],
      subject: "Trainer Booking Confirmation"
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
end
