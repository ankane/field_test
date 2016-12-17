FieldTest::Engine.routes.draw do
  resources :experiments, only: [:show]
  get "participants/:id", to: "participants#show", constraints: {id: /.+/}, as: :participant
  root "experiments#index"
end
