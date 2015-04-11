set :stage, :production
set :rails_env, "production"
set :application, "niu_niu"
set :branch, "master"
set :user, "lankr"
set :deploy_to, "/srv/#{fetch(:application)}"

server '115.29.240.213', user: 'lankr', roles: %w{web app}, my_property: :my_value
