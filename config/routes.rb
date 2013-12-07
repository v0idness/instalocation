Tweeporter::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }
  resources :users

  get "events/index"

  get "home/index"

  get "events/add"
  
  get "confirmation/index"

	default_url_options :host => "localhost:3000"
  resources :events 
 
  root to: "home#index"
end
