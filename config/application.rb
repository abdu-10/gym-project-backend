require_relative "boot"

require "rails/all"

# --- KEEPING YOUR FIX FOR THE EMAIL ERROR ---
require 'uri'
URI.singleton_class.send(:alias_method, :encode, :encode_www_form_component) unless URI.respond_to?(:encode)
# -------------------------------------------

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GymProject
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    
    # --- SECURITY UPGRADE: ENABLE COOKIES ---
    # 1. Ensure we are in API mode
    config.api_only = true

    # 2. Manually add back the middleware for Cookies and Sessions.
    #    (Rails API removes these by default, but we need them for HttpOnly auth).
    config.middleware.use ActionDispatch::Cookies
    
    # --- UPDATED: SET EXPIRATION TO 1 YEAR ---
    # We added 'expire_after: 1.year' so the PWA stays logged in "forever".
    config.middleware.use ActionDispatch::Session::CookieStore, 
      key: '_gym_project_session',
      expire_after: 1.year 
    
    # 3. Strict protection so other sites can't steal our cookies
    config.action_dispatch.cookies_same_site_protection = :strict
    # ----------------------------------------
  end
end