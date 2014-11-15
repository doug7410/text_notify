Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", registrations: 'users/registrations' }

  
  root to: "pages#front"

  resources :customers
  resources :notifications, only: [:index, :new, :create]

  get '/sent_notifications', to: 'notifications#sent'
  get '/pending_notifications', to: 'notifications#pending'
  
  delete '/destroy_pending_notification', to: 'notifications#destroy_pending'
  
  post '/send_pending_notification', to: 'notifications#send_notification'

  get 'ui(/:action)', controller: 'ui'
end
