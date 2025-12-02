class RegistrationsController < ApplicationController

  def create
    # 1. Handle Params
    plan_name = params.dig(:registration, :plan) || params[:plan]
    payment_method = params.dig(:registration, :payment, :method)
    
    # Get tokens
    stripe_token = params.dig(:registration, :payment, :stripe_token)
    paypal_order_id = params.dig(:registration, :payment, :paypal_order_id)

    plan = Plan.find_by(name: plan_name)

    if plan.nil?
      render json: { error: "Plan not found: #{plan_name}" }, status: :not_found
      return
    end

    # 2. Build Account Data
    account_data = {
      name: params.dig(:registration, :account, :name),
      email: params.dig(:registration, :account, :email),
      password: params.dig(:registration, :account, :password),
      password_confirmation: params.dig(:registration, :account, :password_confirmation),
      profile_photo: params.dig(:registration, :account, :profile_photo),
      role: "member"
    }

    # 3. Validation Checks
    if payment_method == 'card' && stripe_token.nil?
       render json: { error: "Stripe token not provided." }, status: :unprocessable_entity
       return
    end

    if payment_method == 'paypal' && paypal_order_id.nil?
      render json: { error: "PayPal Order ID not provided." }, status: :unprocessable_entity
      return
   end

    ActiveRecord::Base.transaction do
      # 4. Create the user
      @user = User.create!(account_data)

      # --- CRITICAL VARIABLES DEFINED HERE ---
      # These must be defined BEFORE the if/else block so they can be used later
      transaction_id = nil
      amount_paid = plan.price_in_cents 
      payment_status = 'failed'
      # -------------------------------------

      # 5. PROCESS PAYMENT
      if payment_method == 'card'
        # --- STRIPE LOGIC ---
        customer = Stripe::Customer.create(
          email: @user.email,
          name: @user.name,
          source: stripe_token
        )
        charge = Stripe::Charge.create(
          customer: customer.id,
          amount: amount_paid,
          currency: 'usd',
          description: "FITELITE - #{plan.name} Membership"
        )
        transaction_id = charge.id
        payment_status = 'succeeded'

      elsif payment_method == 'paypal'
        # --- PAYPAL LOGIC ---
        request = PaypalServerSdk::Orders::OrdersCaptureRequest.new(paypal_order_id)
        request.prefer("return=representation")
        
        begin
          response = PAYPAL_CLIENT.execute(request)
          
          if response.result.status != 'COMPLETED'
            raise "PayPal payment not completed. Status: #{response.result.status}"
          end
          
          transaction_id = response.result.id
          payment_status = 'succeeded'

        rescue PaypalServerSdk::ErrorException => e
          raise "PayPal API Error: #{e.result.message}"
        end
      end

      # 6. LOG THE PAYMENT
      # This crashed before because 'amount_paid' wasn't defined in your previous version
      Payment.create!(
        user: @user,
        amount_cents: amount_paid,
        currency: 'usd',
        payment_method: payment_method,
        transaction_id: transaction_id,
        status: payment_status,
        description: "Membership: #{plan.name}"
      )

      # 7. Create Membership
      @membership = Membership.create!(
        user: @user,
        plan: plan
      )

      # 8. Log in & Session
      session[:user_id] = @user.id
      photo_url = @user.profile_photo.attached? ? url_for(@user.profile_photo) : nil

      # 9. Send Welcome Email
      UserMailer.with(user: @user).welcome_email.deliver_later

      render json: { 
        message: "User and membership created successfully!",
        user: { 
          id: @user.id, 
          name: @user.name, 
          email: @user.email,
          joined_at: @user.created_at,
          photo_url: photo_url
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
    puts "!!!!!!!!!!!!!!!! REGISTRATION CRASH !!!!!!!!!!!!!!!!"
    puts "ERROR: #{e.message}"
    puts e.backtrace.join("\n") # Print stack trace to console
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def registration_params
    params.require(:registration).permit(
      :plan,
      account: [ :name, :email, :password, :password_confirmation, :profile_photo ],
      payment: [ :method, :nameOnCard, :mpesaPhone, :stripe_token, :paypal_order_id ]
    )
  end
end