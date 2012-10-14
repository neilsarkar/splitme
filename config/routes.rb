Splitme::Application.routes.draw do
  namespace :api do
    resources :plans, only: [:index, :create, :show]
    match "/plans/:id/collect/:participant_id" => "plans#collect", via: :post
    match "/plans/:plan_token/join" => "plans#join", via: :post
    match "/plans/:plan_token/preview" => "plans#preview"

    resources :users, only: [:create] do
      post :collect, on: :member
    end
    match "/users/authenticate" => "users#authenticate", via: :post

    match "/" => "hi#hi"
  end

  mount JasmineRails::Engine => "/specs" if Rails.env.development?

  match "/:token" => "site#hi"
  root to: "site#hi"
end
