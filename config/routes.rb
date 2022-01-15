Rails.application.routes.draw do
  resources :schools
 
  
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "articles#index"
  #get "/articles", to："articles#index"
  resources :articles do 
    resources :comments
  end
  resources :areas
end
