Tweeporter::Application.routes.draw do
  get "events/index"

  get "home/index"

  get "events/add"


  resources :events 
 
  root to: "home#index"
end
