Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/a', as: 'rails_admin'
  root 'portal#index'

  devise_for :users, controllers: {
                                    sessions:      'users/sessions',
                                    confirmations: 'users/confirmations',
                                    registrations: 'users/registrations',
                                    passwords:     'users/passwords',
                                    unlocks:       'users/unlocks'
                                  }

  resources :users do
    resources :my_posts
  end

  resources :posts

  namespace :api do
    devise_scope :user do
      post    'sessions'      => 'sessions#create',       :as => 'login'
      delete  'sessions'      => 'sessions#destroy',      :as => 'logout'
      post    'registrations' => 'registrations#create',  :as => 'register'
    end
  end

end
