FieldTest::Engine.routes.draw do
  resources :experiments, only: [:show]
  resources :participants, only: [:show]
  root "experiments#index"
end
