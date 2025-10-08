Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :api_keys, only: [:create, :index, :destroy]
      resources :vaults do
        post :share, on: :member
        delete "share/:user_id", to: "vaults:unshare"
        resources :documents, only: [:index, :create]
      end
      resources :documents, only: [:show, :update, :destroy]

      post "/login", to: "sessions#create"
      post "/signup", to: "users#create"
      get "/owner", to: "users#show"
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check



  

  # Defines the root path route ("/")
  # root "posts#index"
end
