Tweeporter::Application.routes.draw do
  get "home/index"

  resources :events
 
  root to: "home#index"
end
