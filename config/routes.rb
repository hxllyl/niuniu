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
    resources :posts
  end

  namespace :api do
    devise_scope :user do
      post    'sessions'      => 'sessions#create',       :as => 'login'
      delete  'sessions'      => 'sessions#destroy',      :as => 'logout'
      post    'registrations' => 'registrations#create',  :as => 'register'
    end
  end

end
