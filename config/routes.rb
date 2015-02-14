Rails.application.routes.draw do
  root to: 'home#index'

  get 'home/index'
  get 'home/about'
  get 'home/mentions'
  get 'home/notifications'

  devise_for :users, controllers: {
    registrations: 'registrations',
    omniauth_callbacks: 'omniauth_callbacks'
  }

  resources :users, only: [:index, :show] do
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
    get :unauthorized
    get :not_found
    get :internet_server_error
  end
end
