require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :business_owners, controllers: { registrations: 'business_owners/registrations' }

  
  root to: "pages#front"
  get '/dashboard', to: "pages#dashboard", as: "dashboard"

  resources :customers
  resources :notifications, only: [:index, :create]
  resources :groups 
  resources :group_notifications, only: [:create]

  resources :memberships, only: [:create, :destroy]

  post '/twilio_callback', to: 'twilio_callback#status'

  get 'ui(/:action)', controller: 'ui'
  
  mount Sidekiq::Web, at: '/sidekiq'
end
