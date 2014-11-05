Rails.application.routes.draw do
  devise_for :users
  root to: "ui#index"

  get 'ui(/:action)', controller: 'ui'
end
