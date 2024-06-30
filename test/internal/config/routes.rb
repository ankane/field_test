Rails.application.routes.draw do
  resources :users, only: [:index]
  get "exclude", to: "users#exclude"
  mount FieldTest::Engine, at: "field_test"
end
