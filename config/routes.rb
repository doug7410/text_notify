Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  
  root to: "pages#front"

  resources :customers

  get 'ui(/:action)', controller: 'ui'
end
