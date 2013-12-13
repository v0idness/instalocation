Tweeporter::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :users

  get "events/index"

  get "home/index"

  get "events/add"
  
  get "confirmation/index"

  resources :locations

	default_url_options :host => "localhost:3000"

  resources :events 
  
  root to: "events#index"
 
  

  resources :events do
    member do 
        post 'create'
    end
  end

end
