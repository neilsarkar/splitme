Splitme::Application.routes.draw do
  constraints :subdomain => "api" do
    scope :module => "api", :as => "api" do
      resources :plans, only: [:index, :create, :show]
      match "/plans/:id/collect/:participant_id" => "plans#collect", via: :post
      resources :users, only: [:create] do
        post :collect, on: :member
      end
      match "/users/authenticate" => "users#authenticate", via: :post
    end
  end

  mount JasmineRails::Engine => "/specs" if Rails.env.development?

  root to: "site#hi"
end
