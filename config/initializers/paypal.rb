# config/initializers/paypal.rb
require 'paypal_server_sdk'

PayPal::Server::SDK.configure do |config|
  config.client_id = Rails.application.credentials.paypal[:client_id]
  config.client_secret = Rails.application.credentials.paypal[:client_secret]
  
  # Change to "PRODUCTION" when you go live
  config.environment = "SANDBOX" 
end

# Create a global client helper we can use in controllers
PAYPAL_CLIENT = PayPal::Server::SDK::PayPalClient.new