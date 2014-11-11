Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  
  root to: "pages#front"

  resources :customers
  resources :notifications, only: [:new, :create]

  get 'ui(/:action)', controller: 'ui'
end
