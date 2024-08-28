Rails.application.routes.draw do
  get "home/index"
  namespace :api do
    namespace :v1 do
      resources :recipes, only: [ :index, :show ]
      resources :ingredients, only: [ :index ]
    end
  end

  root "home#index"
end
