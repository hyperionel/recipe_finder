Rails.application.routes.draw do
  get "home/index"
  namespace :api do
    namespace :v1 do
      resources :recipes, only: [ :index, :show ]
      resources :ingredients do
        get "autocomplete", on: :collection
        get "surprise", on: :collection
      end
    end
  end

  root "home#index"
end
