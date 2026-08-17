Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#show"

  get "login", to: "sessions#new", as: :login
  get "auth/:provider/callback", to: "sessions#create"
  post "auth/:provider/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
  delete "logout", to: "sessions#destroy", as: :logout
  post "login/email", to: "passwordless_sessions#create", as: :email_login
  get "login/email/:token", to: "passwordless_sessions#show", as: :verify_login

  resources :patrons, except: :destroy
  resources :bookings, except: :destroy do
    resources :booking_documents, only: %i[show create] do
      get :open, on: :member
    end
  end
end
