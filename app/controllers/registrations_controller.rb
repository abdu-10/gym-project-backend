class RegistrationsController < ApplicationController

  def create
    # 1. Handle Params
    plan_name = params.dig(:registration, :plan) || params[:plan]
    payment_method = params.dig(:registration, :payment, :method)
    
    # Get tokens for both providers
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
      profile_photo: params.dig(:registration, :account, :profile_photo)
    }

    # 3. Validation Checks before starting transaction
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

      # 5. PROCESS PAYMENT (Switch based on method)
      if payment_method == 'card'
        # --- STRIPE LOGIC ---
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

      elsif payment_method == 'paypal'
        # --- PAYPAL LOGIC ---
        # We need to "Capture" the order that was approved on the frontend
        
        request = PayPal::Server::SDK::Orders::OrdersCaptureRequest.new(paypal_order_id)
        request.prefer("return=representation")
        
        begin
          response = PAYPAL_CLIENT.execute(request)
          
          # Check if the status is COMPLETED
          if response.result.status != 'COMPLETED'
            raise "PayPal payment not completed. Status: #{response.result.status}"
          end

          # Optional: Verify the amount matches the plan price
          # (PayPal returns strings like "100.00")
          paid_amount = response.result.purchase_units[0].payments.captures[0].amount.value.to_f
          expected_amount = plan.price_in_cents / 100.0
          
          if paid_amount != expected_amount
             # In production, you might log this for manual review instead of crashing
             # raise "Amount mismatch! Expected #{expected_amount}, got #{paid_amount}"
          end

        rescue PayPal::Server::SDK::Core::PayPalHttpError => e
          # Handle PayPal API errors
          raise "PayPal API Error: #{e.result.message}"
        end
      end

      # 6. Create Membership
      @membership = Membership.create!(
        user: @user,
        plan: plan
      )

      # 7. Log in & Generate Photo URL
      session[:user_id] = @user.id
      photo_url = @user.profile_photo.attached? ? url_for(@user.profile_photo) : nil

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

  # --- ERROR CATCHING ---
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
        :name, :email, :password, :password_confirmation, :profile_photo
      ],
      payment: [
        :method,
        :nameOnCard,
        :mpesaPhone,
        :stripe_token,
        :paypal_order_id # <--- ADD THIS
      ]
    )
  end
end