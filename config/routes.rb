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

  resources :posts do
    collection do
      get :resources_list
    end
  end

  namespace :api do
    devise_scope :user do
      post    'sessions'      => 'sessions#create',       :as => 'login'
      delete  'sessions'      => 'sessions#destroy',      :as => 'logout'
      post    'registrations' => 'registrations#create',  :as => 'register'
    end
    namespace :posts do
      get   :list
      get   :my_list
      get   :show
      post  :create
    end

    namespace :follow_ships do
      get :my_followers
      get :my_followings
      get :joint_followers
      get :joint_followings
    end
  end

end
