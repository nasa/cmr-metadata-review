Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root 'dashboard#index'

  get 'daac/*path', to: 'dashboard#index'
  get 'collections/*path', to: 'dashboard#index'
  get 'granules/*path', to: 'dashboard#index'
  get 'signin', to: 'dashboard#index'
  get 'signup', to: 'dashboard#index'

  mount_devise_token_auth_for 'User', at: 'auth'
  get '/auth/:provider/callback', to: 'sessions#create'

  resources :dashboard, only: :index
  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  namespace :api do
    namespace :v1 do
      resources :daac, only: [:index, :show]
      resources :collections, only: [:index, :show] do
        put 'recommend'
        put 'random_granule'
        put 'review'
        put 'take_for_review'
      end
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
