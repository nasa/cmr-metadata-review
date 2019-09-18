Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope format: false do
    get '/elb_status', to: 'site#elb_status'

    devise_for :users, :controllers => {
      :omniauth_callbacks => "login"
    }

    get '/login', to: 'login#urs'

    # https://github.com/plataformatec/devise/issues/1390
    devise_scope :user do
      root to: "devise/sessions#new"
      get '/session/new' => 'devise/sessions#new', as: :new_user_session
      get '/session/sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
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
        post "pull_latest"
        post "ingest_specific"
      end
    end
    resources :comments
    resources :reviews
    resources :records do
      member do
        post "complete"
        post "associate_granule_to_collection"
      end

      collection do
        get "finished"
        get "navigate"
        put "allow_updates"
        put "stop_updates"
        post "revert"
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

    # https://stackoverflow.com/questions/21654826/how-to-rescue-page-not-found-404-in-rails
    # The “a” is actually a parameter in the Rails 3 Route Globbing technique. For example,
    # if your url was /this-url-does-not-exist, then params[:a] equals “/this-url-does-not-exist”.
    match '*a', :to => 'errors#routing', via: :get
  end
end
