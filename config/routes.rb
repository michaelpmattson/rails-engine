Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'items/find_all',     to: 'items/find#index'
      resources :items do
        get 'merchant',         to: 'items/merchant#show'
      end

      get 'merchants/find',     to: 'merchants/find#show'
      get 'merchants/find_all', to: 'merchants/find#index'
      resources :merchants, only: [:index, :show] do
        get 'items', to: 'merchant_items#index'
      end

      namespace :revenue do
        resources :merchants, only: :show
      end
    end
  end
end
