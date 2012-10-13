Splitme::Application.routes.draw do
  constraints :subdomain => "api" do
    scope :module => "api", :as => "api" do
      resources :users, only: [:create]
      resources :plans, only: [:create, :show]
    end
  end

  root to: "site#hi"
end
