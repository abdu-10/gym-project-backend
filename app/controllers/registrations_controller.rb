class RegistrationsController < ApplicationController

  def create
    # --- CHANGE 1: Handle FormData Structure ---
    # When uploading files, data comes in slightly differently (FormData).
    # We use params.dig to safely find the values, whether they are JSON or FormData.
    
    plan_name = params.dig(:registration, :plan) || params[:plan]
    stripe_token = params.dig(:registration, :payment, :stripe_token) || params[:stripe_token]

    plan = Plan.find_by(name: plan_name)

    if plan.nil?
      render json: { error: "Plan not found: #{plan_name}" }, status: :not_found
      return
    end

    # --- CHANGE 2: Build Account Data Manually ---
    # We construct the user data hash manually to ensure we grab the file object correctly.
    account_data = {
      name: params.dig(:registration, :account, :name),
      email: params.dig(:registration, :account, :email),
      password: params.dig(:registration, :account, :password),
      password_confirmation: params.dig(:registration, :account, :password_confirmation),
      profile_photo: params.dig(:registration, :account, :profile_photo) # <--- THIS IS THE PHOTO FILE
    }

    if params.dig(:registration, :payment, :method) == 'card' && stripe_token.nil?
       render json: { error: "Stripe token not provided." }, status: :unprocessable_entity
       return
    end

    ActiveRecord::Base.transaction do
      # Create the user with the photo
      @user = User.create!(account_data)

      if stripe_token
        customer = Stripe::Customer.create(
          email: @user.email,
          name: @user.name,
          source: stripe_token
        )
        Stripe::Charge.create(
          customer: customer.id,
          amount: plan.price_in_cents,
          currency: 'usd',
          description: "FITELITE - #{plan.name} Membership"
        )
      end

      @membership = Membership.create!(
        user: @user,
        plan: plan
      )

      session[:user_id] = @user.id

      # --- CHANGE 3: Generate the Photo URL ---
      # If a photo was attached, ask Rails for its URL.
      photo_url = @user.profile_photo.attached? ? url_for(@user.profile_photo) : nil

      render json: { 
        message: "User and membership created successfully!",
        user: { 
          id: @user.id, 
          name: @user.name, 
          email: @user.email,
          joined_at: @user.created_at,
          photo_url: photo_url # <--- SEND IT BACK TO REACT
        },
        membership: { plan: @membership.plan.name }
      }, status: :created
    end

  rescue Stripe::CardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue Stripe::StripeError => e
    render json: { error: "Payment system error: #{e.message}" }, status: :internal_server_error
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue => e
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "!!!!!!!!!! REGISTRATION CRASH !!!!!!!!!!"
    puts "ERROR: #{e.message}"
    puts e.backtrace.join("\n")
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def registration_params
    params.require(:registration).permit(
      :plan,
      account: [
        :name,
        :email,
        :password,
        :password_confirmation,
        :profile_photo # <--- CHANGE 4: Permit the photo param
      ],
      payment: [
        :method,
        :nameOnCard,
        :mpesaPhone,
        :stripe_token
      ]
    )
  end
end