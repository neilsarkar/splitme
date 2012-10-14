Splitme::Application.routes.draw do
  namespace :api do
    match "/plans/:plan_id/collect/:participant_id" => "commitments#collect", via: :post

    match "/participants/:plan_token/create" => "participants#create", via: :post

    resources :plans, only: [:index, :create, :show]
    match "/plans/:plan_token/preview" => "plans#preview"

    resources :users, only: [:create]
    match "/users/authenticate" => "users#authenticate", via: :post

    match "/" => "hi#hi"
  end

  mount JasmineRails::Engine => "/specs" if Rails.env.development?

  match "/:token" => "site#hi"
  root to: "site#hi"
end
