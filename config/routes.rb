Rails.application.routes.draw do
  resources :users, only: [ :new, :create ]
  resources :groups do
    member do
      get :invite
      post :invite, action: :send_invite
    end
  end
  resources :lists do
    resources :meals, only: [ :create, :update, :destroy ]
    patch :meals, to: "meals#update"

    resources :items, only: [ :index, :new, :create ]
  end

  resource :session
  patch '/switch_group', to: 'sessions#switch_group', as: :switch_group
  resources :passwords, param: :token

  resources :items do
    resources :subscribers, only: [ :create ]
  end

  resource :unsubscribe, only: [ :show ]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  # get "/items", to: "items#index"
  #
  # get "/items/new", to: "items#new"
  # post "/items", to: "items#create"
  #
  # get "/items/:id", to: "items#show"
  #
  # get "/items/:id/edit", to: "items#edit"
  # patch "/items/:id", to: "items#update"
  # put "/items/:id", to: "items#update"
  #
  # delete "/items/:id", to: "items#destroy"

  root "lists#index"
end
