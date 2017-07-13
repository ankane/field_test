FieldTest::Engine.routes.draw do
  resources :experiments, only: [:show]
  resources :memberships, only: [:update]
  get "participants/:id", to: "participants#show", constraints: {id: /.+/}, as: :participant
  root to: "experiments#index"
end
