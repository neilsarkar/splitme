Splitme::Application.routes.draw do
  namespace :api do
    match "/commitments/:plan_token" => "commitments#create", via: :post
    match "/plans/:plan_id/charge/:participant_id" => "commitments#charge", via: :post

    match "/participants/:plan_token/create" => "participants#create", via: :post

    resources :plans, only: [:index, :create, :show] do
      post :collect, :on => :member
    end
    match "/plans/:plan_token/preview" => "plans#preview"

    resources :users, only: [:create]
    match "/users/authenticate" => "users#authenticate", via: :post
    match "/users/update" => "users#update", via: :post

    match "/" => "hi#hi"
  end

  mount JasmineRails::Engine => "/specs" if Rails.env.development?

  match "/:token" => "site#hi"
  root to: "site#hi"
end
