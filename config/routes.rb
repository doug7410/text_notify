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

  resources :customers, except: [:destroy] do
    collection { post :import }
  end
  resources :notifications, only: [:index, :create]
  resources :groups 
  resources :group_notifications, only: [:create]
  resources :memberships, only: [:create, :destroy]
  resources :inquiries, only: [:create, :new]
  resources :account_settings, except: [:destroy]
  resources :logs, only: [:index]
  resources :queue_item, only: [:destroy]

  namespace :admin do
    resources :business_owners, only: [:index]
  end

  post '/send_queue_item', to: 'notifications#send_queue_item'

  post '/sms_operator', to: 'sms_operator#sms_handler'

  post '/twilio_callback', to: 'twilio_callback#status'

  
  mount Sidekiq::Web, at: '/sidekiq'
  get '/:action', controller: 'pages'
end
