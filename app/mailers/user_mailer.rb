class UserMailer < ApplicationMailer
  def password_reset
    @user = params[:user]
    @token = params[:token]
    
    # POINT TO YOUR FRONTEND URL (Vite default is 5173)
    @reset_url = "http://localhost:5173/reset-password?token=#{@token}"

    mail(to: @user.email, subject: "Reset your FitElite password")
  end
  
  def welcome_email
    @user = params[:user]
    
    # We use safe navigation (&.) just in case the plan is missing
    @plan_name = @user.plan&.name || "Member"
    
    # Points to your Login page
    @dashboard_url = "http://localhost:5173/login"
    
    mail(to: @user.email, subject: "Welcome to the Elite.")
  end
end