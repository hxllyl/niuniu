Rails.application.routes.draw do

  namespace :admin do
    resources :users do
      collection do
        get :search
        get :contacted
        get :registered
      end
    end

    resources :banners
    resources :posts

    resources :messages, only: [:index, :new, :create, :destroy]
    root 'users#search'
  end

  root 'portal#index'

  devise_for :users, controllers: {
                                    sessions:      'users/sessions',
                                    confirmations: 'users/confirmations',
                                    registrations: 'users/registrations',
                                    passwords:     'users/passwords',
                                    unlocks:       'users/unlocks'
                                  }

  namespace :users do
    resources :messages do
    end
  end

  resources :users, only: [ :show, :edit, :update ] do
    member do
      get :my_tenders
      get :my_followers
      get :system_infos
      get :my_level
      get :edit_my_level
      put :update_my_level
      get :about_us
    end
    patch :add_following, on: :collection

    get :delete_relation, on: :collection
    
    patch :reset_password, on: :collection

    resources :my_posts do
      member do
        patch :update
      end
      collection do
        get :get_select_infos
        post :update_position
      end
      resources :tenders, only: [ :show ]
    end
  end

  resources :posts, only: [ :index, :show ] do
    collection do
      get :resources_list
      get :needs_list
      get :user_list
      get :user_resources_list
      get :download_posts
      get :key_search
    end
    member do
      post :tender
      put  :complete
      get  :my_tender
      get  :his_tender
    end
  end

  resources :follow_ships, only: [ :create, :destroy ]

  resources :valid_codes, only: [ :create ] do
    get :_valid, on: :collection
  end

  resources :photos, only: [ :index ] do
    post :upload, on: :collection
  end

  resources :areas, only: [:show]
  resources :complaints, only: [ :create ]
  resources :comments, only: [ :create ]

  namespace :api do
    devise_scope :user do
      post    'sessions'      => 'sessions#create',       :as => 'login'
      delete  'sessions'      => 'sessions#destroy',      :as => 'logout'
      post    'registrations' => 'registrations#create',  :as => 'register'
    end

    resources :banners, only: [:index]

    resources :messages do
      post :device_methods, on: :collection
      post :update_messages, on: :collection
      post :destroy_messages, on: :collection
    end

    resources :base_cars, only: [:index]

    namespace :posts do
      get   :list
      get   :my_list
      get   :my_tenders
      get   :user_list
      get   :show
      post  :create
      post  :tender
      put   :complete
      post  :update_all
      put  :change_position
      delete :destroy
      put :del_my_tender
      get :search
      get :tender_status
    end

    resources :valid_codes, only: [:index] do
      get :validate_code, on: :collection
    end

    resources :areas, only: [:index] do
    end

    namespace :follow_ships do
      get   :my_followers
      get   :my_followings
      get   :joint_followers
      get   :joint_followings
      post  :create
      put   :unfollow
    end

    namespace :complaints do
      post :create
    end

    namespace :comments do
      get  :list
      post :create
      post :reply
    end

    namespace :users do
      get :list
      get :has_updated
      post :update_level
      patch :change_password
      patch :reset_password
      put   :update
      get :show
    end

    resources :phone_lists, only: [:index] do
      post :contact_list, on: :collection
      get :send_invite_message, on: :collection
    end
  end

  # mount RailsAdmin::Engine => '/a', as: 'rails_admin'

end
