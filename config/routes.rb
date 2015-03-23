Rails.application.routes.draw do

  root 'portal#index'

  devise_for :users, controllers: {
                                    sessions:      'users/sessions',
                                    confirmations: 'users/confirmations',
                                    registrations: 'users/registrations',
                                    passwords:     'users/passwords',
                                    unlocks:       'users/unlocks'
                                  }

  resources :users do
    member do
      get :my_tenders
      get :my_followers
      get :system_infos
      get :my_level
      get :edit_my_level
      put :update_my_level
      get :about_us
    end
    resources :my_posts do
      resources :tenders
    end
  end

  resources :posts do
    collection do
      get :resources_list
      get :user_list
    end
  end

  resources :valid_codes do
    get :_valid, on: :collection
  end

  resources :areas, only: [:show]
  resources :complaints, only: [ :create ]

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
      post  :tender
      put   :complete
    end
    
    resources :valid_codes do
    end

    namespace :follow_ships do
      get :my_followers
      get :my_followings
      get :joint_followers
      get :joint_followings
    end

    namespace :complaints do
      post :create
    end
  end

  # mount RailsAdmin::Engine => '/a', as: 'rails_admin'

end
