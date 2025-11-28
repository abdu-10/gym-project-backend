# app/controllers/contacts_controller.rb
class ContactsController < ApplicationController

  def create
    # This is where we get the data from the React form
    contact_data = contact_params

    # Tell the ContactMailer to send the email
    # .deliver_now sends it immediately
    ContactMailer.contact_email(contact_data).deliver_now

    # Send back a "200 OK" response
    render json: { message: "Message sent successfully!" }, status: :ok

  rescue => e
    puts "CONTACT FORM ERROR: #{e.message}"
    # If anything goes wrong, send back a 422 error
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  # Strong Params!
  # We'll expect a `contact` object in the JSON body
  def contact_params
    params.require(:contact).permit(:name, :email, :phone, :subject, :message)
  end
end