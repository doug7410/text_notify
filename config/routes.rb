require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :business_owners, controllers: { registrations: 'business_owners/registrations' }


  devise_scope :business_owner do
    authenticated  do
      root to: 'pages#dashboard'
    end

    unauthenticated do
      root to: 'devise/sessions#new', as: 'unauthenticated_root'
    end
  end  

  get '/dashboard', to: "pages#dashboard", as: "dashboard"

  resources :customers
  resources :notifications, only: [:index, :create]
  resources :groups 
  resources :group_notifications, only: [:create]
  resources :memberships, only: [:create, :destroy]
  resources :inquiries, only: [:create, :new]

  post '/sms', to: 'sms#text'

  post '/twilio_callback', to: 'twilio_callback#status'

  get 'ui(/:action)', controller: 'ui'
  
  mount Sidekiq::Web, at: '/sidekiq'
end
