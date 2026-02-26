Rails.application.routes.draw do
  # Personal homepage (no auth required)
  root "pages#home"
  get "about", to: "pages#about"
  get "links", to: "pages#links"
  get "apps", to: "pages#apps"
  get "guestbook", to: "pages#guestbook"
  post "guestbook", to: "pages#sign_guestbook"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # All shopping routes live under /shopping/
  scope "/shopping" do
    resources :users, only: [ :new, :create ]
    resources :groups do
      member do
        get :invite
        post :invite, action: :send_invite
        delete :leave
      end
    end

    resources :group_invitations, only: [ :index ] do
      member do
        post :accept
        post :decline
      end
    end
    resources :lists do
      collection do
        get :all
      end
      resources :meals, only: [ :create, :update, :destroy ]
      patch :meals, to: "meals#update"

      resources :items, only: [ :index, :new, :create ]
      resources :list_items, only: [ :update, :destroy ] do
        member do
          patch :toggle
          patch :reorder
        end
      end
    end

    resource :session
    patch "/switch_group", to: "sessions#switch_group", as: :switch_group
    resources :passwords, param: :token

    resources :items do
      collection do
        get :search
      end
      resources :subscribers, only: [ :create ]
    end

    resource :unsubscribe, only: [ :show ]

    get "list" => "lists#show_current", as: :current_list_tab
    get "meals" => "lists#meals", as: :meals_tab
    patch "select_list/:id" => "lists#select", as: :select_list

    get "/", to: "lists#home", as: :shopping_home
  end
end
