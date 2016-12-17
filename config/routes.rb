FieldTest::Engine.routes.draw do
  resources :experiments, only: [:show]
  root "experiments#index"
end
