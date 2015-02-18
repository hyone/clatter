
Rails.application.routes.draw do
  root to: 'home#index'

  get '/about',         to: 'home#about'
  get '/mentions',      to: 'home#mentions'
  get '/notifications', to: 'home#notifications'

  # devise_for :users, skip: [:sessions, :registrations], path: :u, controllers: {
  devise_for :users, skip: [:sessions, :registrations], controllers: {
    registrations: 'registrations',
    passwords: 'passwords',
    omniauth_callbacks: 'omniauth_callbacks'
  }
  devise_scope :user do
    # signin and signout
    get    '/login'    => 'devise/sessions#new',     as: :new_user_session
    post   '/login'    => 'devise/sessions#create',  as: :user_session
    delete '/logout'   => 'devise/sessions#destroy', as: :destroy_user_session
    # signup
    get    '/signup'   => 'registrations#new',       as: :new_user_registration
    post   '/signup'   => 'registrations#create',    as: :user_registration
    # settings & cancell
    get    '/settings' => 'registrations#edit',      as: :edit_user_registration
    put    '/settings' => 'registrations#update'
    get    '/cancel'   => 'registrations#cancel',    as: :cancel_user_registration
    # account deletion
    delete '/u' => 'devise/registrations#destroy'
  end

  resources :users, only: [:index, :show], path: 'u' do
    member do
      get :with_replies
      get :favorites
      get :following
      get :followers
    end
  end
  resources :authentications, only: [:index, :destroy]
  resources :favorites,       only: [:create, :destroy]
  resources :follows,         only: [:create, :destroy]
  resources :messages,        only: [:create, :destroy]

  resource :errors, only: [] do
    get :bad_request
    get :unauthorized
    get :not_found
    get :internet_server_error
  end
end
