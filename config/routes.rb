
Rails.application.routes.draw do
  root to: 'home#index'

  get '/about',         to: 'home#about'
  get '/mentions',      to: 'home#mentions'
  get '/notifications', to: 'home#notifications'
  get '/search',        to: 'home#search'

  # devise_for :users, skip: [:sessions, :registrations], path: :u, controllers: {
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    passwords: 'users/passwords',
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'settings'
  }
  devise_scope :user do
    # signin and signout
    get    '/login'    => 'devise/sessions#new',           as: :new_user_session
    post   '/login'    => 'devise/sessions#create',        as: :user_session
    delete '/logout'   => 'devise/sessions#destroy',       as: :destroy_user_session
    # signup
    get    '/signup'   => 'users/registrations#new',       as: :new_user_registration
    post   '/signup'   => 'users/registrations#create',    as: :user_registration
    get    '/cancel'   => 'users/registrations#cancel',    as: :cancel_user_registration
    # account deletion
    delete '/u/:id'    => 'users/registrations#destroy',   as: :delete_user_registration
    # settings
    get    '/settings/account'  => 'settings#account'
    get    '/settings/password' => 'settings#password'
    get    '/settings/profile'  => 'settings#profile'
    put    '/settings/password' => 'settings#update_password'
    put    '/settings/:section' => 'settings#update_without_password', constraints: { section: /profile/ }
    put    '/settings/:section' => 'settings#update_with_password'
  end

  resources :users, only: [:index, :show], path: 'u' do
    member do
      get :with_replies
      get :favorites
      get :following
      get :followers
      get 'status/:message_id' => 'users#status', as: :status
    end
  end

  # devise_scope :settings do
    # get  :account
    # post :account, action: :account_update
    # get  :password
    # get  :profile
  # end

  resources :authentications, only: [:index, :destroy]
  resources :favorites,       only: [:create, :destroy]
  resources :follows,         only: [:create, :destroy]
  resources :messages,        only: [:create, :destroy]
  resources :retweets,        only: [:create, :destroy]

  resource :errors, only: [] do
    get :bad_request
    get :unauthorized
    get :not_found
    get :internet_server_error
  end
end
