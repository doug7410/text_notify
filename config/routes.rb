Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", registrations: 'users/registrations' }

  
  root to: "pages#front"
  get '/dashboard', to: "pages#dashboard"

  resources :customers
  resources :notifications, only: [:index, :new, :create]
  resources :groups, only: [:index, :create, :show, :update]


  post '/add_to_group/:id/:customer_id', to: "groups#add_customer", as: "add_to_group"
  post '/remove_from_group/:id/:customer_id', to: "groups#remove_customer", as: "remove_from_group"

  get '/sent_notifications', to: 'notifications#sent'
  get '/pending_notifications', to: 'notifications#pending'
  
  delete '/destroy_pending_notification', to: 'notifications#destroy_pending'
  
  post '/send_pending_notification', to: 'notifications#send_notification'

  get 'ui(/:action)', controller: 'ui'
end
