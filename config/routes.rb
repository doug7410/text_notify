Rails.application.routes.draw do
  devise_for :users
  root to: "pages#front"

  get 'ui(/:action)', controller: 'ui'
end
