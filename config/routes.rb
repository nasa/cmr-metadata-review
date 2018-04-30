Rails.application.routes.draw do
  get '/elb_status', to: 'site#elb_status'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  devise_scope :user do
    root to: "devise/sessions#new"
    get '/users/sign_out', to: 'users/sessions#destroy'
  end

  get '/home', to: 'site#home'
  get '/general_home', to: 'site#general_home'

  resources :collections do
    collection do
      put 'refresh'
    end
  end

  get '/collections_search', to: 'collections#search'

  resources :granules do
    member do
      delete "replace"
    end
  end
  resources :comments
  resources :reviews
  resources :records do
    member do
      post "complete"
    end

    collection do
      get "finished"
      get "navigate"
      put "allow_updates"
      put "stop_updates"
      post "batch_complete"
      delete "hide"
    end
  end

  get '/record_refresh', to: 'records#refresh'

  get '/reports/home', to: 'reports#home'
  get '/reports/provider', to: 'reports#provider'
  get '/reports/search', to: 'reports#search'
  get '/reports/selection', to: 'reports#selection'
  get '/reports/review', to: 'reports#review'
  get '/reports/bulk', to: 'reports#bulk'

  #making a convenient path to the rdoc files
  if ENV['SHOW_DOCUMENTATION'] == 'true'
    get "/documentation" => redirect("/doc/index.html")
  end

end
