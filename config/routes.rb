Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  
  root to: "pages#front"

  resources :customers, only: [:new, :create]

  get 'ui(/:action)', controller: 'ui'
end
