class RegistrationsController < ApplicationController
  # This is a JSON API, so we skip this security check
  skip_before_action :verify_authenticity_token

  # This is the 'create' action we defined in our routes.rb
  def create
    # 1. Get all our secure, whitelisted data
    plan_name = registration_params[:plan]
    account_params = registration_params[:account]
    payment_params = registration_params[:payment]
    
    # This is the secret, one-time-use token from React
    stripe_token = payment_params[:stripe_token]
    
    # 2. Find the Plan in our database
    plan = Plan.find_by(name: plan_name)

    if plan.nil?
      render json: { error: "Plan not found: #{plan_name}" }, status: :not_found
      return
    end

    # 3. Make sure we have a token if the method is 'card'
    #    (This check will be important when we add PayPal/M-Pesa)
    if payment_params[:method] == 'card' && stripe_token.nil?
       render json: { error: "Stripe token not provided." }, status: :unprocessable_entity
       return
    end

    # 4. Start our "safety bubble" transaction
    ActiveRecord::Base.transaction do
      # 5. Create a new Customer in your Stripe Dashboard
      #    We use the email from the form and the token as their payment source
      customer = Stripe::Customer.create(
        email: account_params[:email],
        name: account_params[:name],
        source: stripe_token
      )

      # 6. CHARGE THE CUSTOMER!
      #    This uses the customer's new ID and the price_in_cents
      #    from the plan we found in our database.
      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: plan.price_in_cents, # This is why we added this column!
        currency: 'usd', # You can change this to 'kes', 'eur', etc.
        description: "FITELITE - #{plan.name} Membership"
      )

      # 7. If the charge above succeeded, we can now
      #    create the User in *our* database.
      @user = User.create!(account_params)

      # 8. And create the Membership to link them.
      @membership = Membership.create!(
        user: @user,
        plan: plan
      )

      # 9. If we get here, EVERYTHING worked!
      render json: { 
        message: "User and membership created successfully!",
        user: { id: @user.id, name: @user.name, email: @user.email },
        membership: { plan: @membership.plan.name }
      }, status: :created
    end

  # --- NEW ERROR CATCHING ---

  # This catches a "Your card was declined" error from Stripe
  rescue Stripe::CardError => e
    render json: { error: e.message }, status: :unprocessable_entity

  # This catches other Stripe errors (e.g., bad API key)
  rescue Stripe::StripeError => e
    render json: { error: "Payment system error: #{e.message}" }, status: :internal_server_error

  # This catches our validation errors (e.g., "Email has already been taken")
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  
  # This catches any other unexpected crash
  rescue => e
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "!!!!!!!!!! REGISTRATION CRASH !!!!!!!!!!"
    puts "ERROR: #{e.message}"
    puts e.backtrace.join("\n")
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    render json: { error: e.message }, status: :internal_server_error
  end


  private

  # --- UPDATED PARAMS ---
  def registration_params
    params.require(:registration).permit(
      :plan,
      account: [
        :name,
        :email,
        :password,
        :password_confirmation
      ],
      payment: [
        :method,
        :nameOnCard,
        :mpesaPhone,
        :stripe_token  # <-- We now accept the secret token
      ]
    )
  end
end