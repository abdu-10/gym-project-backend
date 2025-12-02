# config/initializers/paypal.rb
require 'paypal_server_sdk'

PAYPAL_CLIENT = PaypalServerSdk::Client.new(
  client_credentials_auth_credentials: PaypalServerSdk::ClientCredentialsAuthCredentials.new(
    o_auth_client_id: Rails.application.credentials.dig(:paypal, :client_id),
    o_auth_client_secret: Rails.application.credentials.dig(:paypal, :client_secret)
  ),
  environment: PaypalServerSdk::Environment::SANDBOX
)