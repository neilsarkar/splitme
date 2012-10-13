Splitme::Application.routes.draw do
  constraints :subdomain => "api" do
    scope :module => "api", :as => "api" do
      resources :users, only: [:index, :create]
    end
  end

  root to: "site#hi"
end
