# app/mailers/contact_mailer.rb
class ContactMailer < ApplicationMailer
  # This is the "From" address for all emails from this mailer
  default from: 'notifications@your-app.com'

  # This is the action that builds our email
  def contact_email(contact_data)
    # The '@data' variable will be available in our email templates
    @data = contact_data

    # Let's make the subject line dynamic!
    new_subject = "New message from #{@data['name']} (#{@data['email']})"

    # This is where the magic happens:
    mail(
      to: "abdubadhawi10@gmail.com", # CHANGE THIS to your personal email
      subject: "New Contact Form Message",
      reply_to: @data["email"]
    )
  end
end
