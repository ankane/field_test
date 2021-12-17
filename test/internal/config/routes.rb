Rails.application.routes.draw do
  resources :users, only: [:index]
  get "exclude", to: "users#exclude"
end
