Rails.application.routes.draw do

  Rails.application.routes.draw do
      devise_for :users, controllers: {
        registrations: 'users/registrations'
      }
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'site#index'

  get '/home', to: 'site#home'
  
  resources :collections
  get '/collections_search', to: 'collections#search'

  resources :granules

  resources :comments

  resources :reviews





  # get '/curators', to: 'site#curators'
  # get '/normal_users', to: 'site#normal_users'

  
  
  # get '/curation_ingest_details', to: 'collection#new'

  # post '/curation_ingest', to: 'collection#create'

  # get '/collection_record_details', to: 'collection#show'
  # get '/collection_record_review', to: 'review#show'
  # post '/collection_comment_update', to: 'comment#update'

  # get '/granule_show', to: 'granule#show'

devise_scope :user do
  get '/users/sign_out', to: 'users/sessions#destroy'
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
