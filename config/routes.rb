Rails.application.routes.draw do

  Rails.application.routes.draw do
      devise_for :users, controllers: {
        registrations: 'users/registrations'
      }
  end

  devise_scope :user do
    root to: "devise/sessions#new"
    get '/users/sign_out', to: 'users/sessions#destroy'
  end

  get '/home', to: 'site#home'
  get '/general_home', to: 'site#general_home'
  
  resources :collections
  get '/collections_search', to: 'collections#search'

  resources :granules
  resources :comments
  resources :reviews
  resources :records
  get '/record_complete', to: 'records#complete'
  get '/record_refresh', to: 'records#refresh'

  get '/reports/home', to: 'reports#home'
  get '/reports/provider', to: 'reports#provider'
  get '/reports/search', to: 'reports#search'
  get '/reports/selection', to: 'reports#selection'

  get '/elb_status', to: 'site#elb_status'

  #making a convenient path to the rdoc files
  if ENV['SHOW_DOCUMENTATION'] == 'true'
    get "/documentation" => redirect("/doc/index.html")
  end
  
end
