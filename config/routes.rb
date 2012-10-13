Splitme::Application.routes.draw do
  constraints :subdomain => "api" do
    scope :module => "api", :as => "api" do
      resources :plans, only: [:create, :show]
      resources :users, only: [:create]
      match "/users/authenticate" => "users#authenticate", via: :post
    end
  end

  root to: "site#hi"
end
