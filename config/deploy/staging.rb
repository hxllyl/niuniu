set :stage, :production

set :rails_env, "production"
set :application, "niu_niu"
set :branch, "dev"
set :user, "lankr"
set :deploy_to, "/srv/#{fetch(:application)}"
# Sh!@#456

server "121.40.204.159", user: "lankr", roles: %w{web app db}