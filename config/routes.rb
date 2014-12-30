Rails.application.routes.draw do
  root to: 'home#index'

  get 'home/index'
  get 'home/about'

  devise_for :users, controllers: {
    registrations: 'registrations',
    omniauth_callbacks: 'omniauth_callbacks'
  }

  resources :users, only: [:index, :show] do
    member do
      get :with_replies
      get :following
      get :followers
    end
  end
  resources :authentications, only: [:index, :destroy]
  resources :relationships,   only: [:create, :destroy]
  resources :messages,        only: [:create, :destroy]
end
