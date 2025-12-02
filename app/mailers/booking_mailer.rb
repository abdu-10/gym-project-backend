class BookingMailer < ApplicationMailer
  # CRITICAL FIX: Ensure the default 'from' address is set, matching what your working mailer uses.
  default from: 'notifications@fitelitegym.com' # CHANGE THIS to match your configured sender email

  # Called via: BookingMailer.with(booking: self).confirmation_email.deliver_later
  def confirmation_email
    @booking = params[:booking]
    @user = @booking.user
    @class = @booking.class_booking
    
    # Simple check for a recipient
    unless @user && @user.email.present?
      Rails.logger.error "MAILER FATAL: Confirmation failed. User or email missing for booking ID #{@booking.id}"
      return
    end

    # The mail call is simple, matching the structure of your working mailer.
    mail(to: @user.email, subject: "Confirmation: Your FitElite Class Booking")
  end

  # Called via: BookingMailer.with(user: user_object, class_booking: class_object).cancellation_email.deliver_now
  def cancellation_email
    @user = params[:user]
    @class = params[:class_booking]
    
    unless @user && @user.email.present?
      Rails.logger.error "MAILER FATAL: Cancellation failed. User or email missing."
      return
    end
    
    # The mail call is simple, matching the structure of your working mailer.
    mail(to: @user.email, subject: "Cancellation Confirmed: FitElite Class")
  end
end