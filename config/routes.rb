require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :business_owners, controllers: { registrations: 'business_owners/registrations' }

  
  root to: "pages#front"
  get '/dashboard', to: "pages#dashboard", as: "dashboard"

  resources :customers
  resources :notifications, only: [:index, :create]
  resources :groups
  resources :group_notifications, only: [:create]

  post '/add_to_group/:id/:customer_id', to: "groups#add_customer", as: "add_to_group"
  post '/remove_from_group/:id/:customer_id', to: "groups#remove_customer", as: "remove_from_group"

  get '/sent_notifications', to: 'notifications#sent'
  get '/pending_notifications', to: 'notifications#pending'
  
  delete '/destroy_pending_notification', to: 'notifications#destroy_pending'
  
  post '/send_pending_notification', to: 'notifications#send_notification'

  post '/twilio_callback', to: 'twilio_callback#status'

  get 'ui(/:action)', controller: 'ui'

  mount Sidekiq::Web, at: '/sidekiq'
end
