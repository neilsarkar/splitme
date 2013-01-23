Splitme::Application.routes.draw do
  namespace :api do
    match "/access_tokens/from_groupme_token" => "access_tokens#from_groupme_token", via: :post

    resources :plans, only: [:index, :create, :show] do
      post :collect, :on => :member
      get :preview, :on => :member
    end
    match "/plans/:id/destroy" => "plans#destroy", via: :post
    match "/plans/:plan_token/commitments" => "commitments#create", via: :post
    match "/plans/:plan_id/charge/:user_id" => "commitments#charge", via: :post

    resources :users, only: [:create]
    match "/users/authenticate" => "users#authenticate", via: :post
    match "/users/update" => "users#update", via: :post
    match "/me" => "users#me"

    match "/" => "hi#hi"
  end

  mount JasmineRails::Engine => "/specs" if Rails.env.development?

  match "/:token" => "site#hi", as: :plan
  match "/*anything" => "site#hi" #serve Backbone routes like /plans/new
  root to: "site#hi"
end
