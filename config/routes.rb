Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "sessions#omniauth"
  post "/auth/:provider/callback", to: "sessions#omniauth"
  get "/auth/:provider", to: redirect { |params, request| "/auth/#{params[:provider]}" }, as: :auth_provider

  scope "(:locale)", locale: /en|vi/ do
    namespace :admin do
      resources :borrow_requests, only: [:index,:show] do
        member do
          get :edit_status
          patch :change_status
        end
      end
    end
    
    root "static_pages#home"

    get "/home",    to: "static_pages#home",    as: :home
    get "/help",    to: "static_pages#help",    as: :help
    get "/contact", to: "static_pages#contact", as: :contact

    get "signup",   to: "users#new",            as: :signup
    post "signup",  to: "users#create"

    get "login",    to: "sessions#new",         as: :login
    post "login",   to: "sessions#create"
    delete "logout",to: "sessions#destroy",     as: :logout

    get "/setup_password", to: "users#setup_password"
    patch "/setup_password", to: "users#update_password"

    resources :users
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
    namespace :admin do
      resources :books
      resources :authors
    end
    resources :books, only: [:show] do
      member do
        post :borrow
        post :add_to_favorite
        delete :remove_from_favorite
        post :write_a_review
      end
    end
  end
end
