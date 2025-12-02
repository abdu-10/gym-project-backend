class PasswordResetsController < ApplicationController
  # Allow anyone to access this (no login required)
  skip_before_action :authorize, only: [:create, :update], raise: false

  def create
    user = User.find_by(email: params[:email])

    if user
      # Generate a secure token valid for 15 minutes
      token = user.signed_id(purpose: :password_reset, expires_in: 15.minutes)
      
      # Send email in background
      UserMailer.with(user: user, token: token).password_reset.deliver_later
    end

    # Always return success to prevent email enumeration (Security Best Practice)
    render json: { message: "If an account with that email exists, we have sent a reset link." }
  end

  def update
    token = params[:token]
    
    begin
      # Find user by verifying the token
      user = User.find_signed!(token, purpose: :password_reset)
      
      if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
        render json: { message: "Password updated successfully! Please log in." }
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render json: { error: "Token has expired or is invalid. Please request a new one." }, status: :unauthorized
    end
  end
end