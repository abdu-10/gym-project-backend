# config/initializers/stripe.rb

# This line securely gets your secret key from the
# encrypted credentials file we just edited.
secret_key = Rails.application.credentials.stripe[:secret_key]

# This line tells the 'stripe' gem to use this key
# for all API requests.
Stripe.api_key = secret_key