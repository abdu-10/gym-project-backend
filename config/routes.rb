Rails.application.routes.draw do
  get "/plans", to: "plans#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.development?
  mount LetterOpenerWeb::Engine => "/letter_opener"
end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Simple browser routes for testimonials (no API namespace) — beginner-friendly
  # Visit http://localhost:3000/testimonials
  # Expose simple routes for Postman/browser: list, show, create, delete
 # config/routes.rb
  resources :testimonials, only: [:index, :show, :create, :update, :destroy]
  
resources :contacts, only: [:create]

post "/registrations", to: "registrations#create"

  # Defines the root path route ("/")
  # root "posts#index"
end
