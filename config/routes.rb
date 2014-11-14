Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", registrations: 'users/registrations' }

  
  root to: "pages#front"

  resources :customers
  resources :notifications, only: [:new, :create]

  get '/sent_notifications', to: 'notifications#sent'
  get '/pending_notifications', to: 'notifications#pending'
  post '/send_pending_notification', to: 'notifications#send_notification'

  get 'ui(/:action)', controller: 'ui'
end
