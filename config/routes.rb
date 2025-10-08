Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Users
      resources :users, only: [:create] do
        collection do
          get 'me'
          post 'regenerate_owner_api_key'
          post 'shared_keys', to: 'users#create_shared_key'
          get 'shared_keys', to: 'users#shared_keys'
          delete 'shared_keys/:id', to: 'users#deactivate_shared_key'
        end
      end
      
      # Vaults and nested documents
      resources :vaults do
        resources :documents do
          collection do
            get 'search'
          end
          member do
            get 'download'
          end
        end
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check  

  # Defines the root path route ("/")
  # root "posts#index"
end
