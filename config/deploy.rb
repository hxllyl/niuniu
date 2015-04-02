set :repo_url, 'git@git.lankr.net:ruby/niuniu.git'
set :use_sudo, false
set :deploy_timestamped, true
set :release_name, Time.now.localtime.strftime("%Y%m%d%H%M%S")
set :keep_releases, 3
set :rvm_ruby_version, "2.1"

set :linked_files, %w{config/config.yml config/database.yml config/unicorn.rb config/boot.rb}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets public/system config/full_lists public/uploads public/images public/assets/index}


namespace :deploy do
  task :start do
    on roles(:app) do
      within release_path do
        set :rvm_path, "~/.rvm"
        execute :bundle, "exec", "unicorn_rails", "-c", File.join(release_path, "config/unicorn.rb"), "-E production", "-D"
      end
    end
  end

  task :stop do
    on roles(:app) do
      pid_file = File.join(release_path, "tmp/pids/unicorn.pid")
      execute "if [[ -e #{pid_file} ]]; then kill $(cat #{pid_file}); fi"
    end
  end

  desc 'Restart application'
  task :restart do
    invoke "deploy:stop"
    invoke "deploy:start"
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  # task :spec_ruby_version do
#     on roles(:app) do
#       execute("echo rvm use 2.1.1 > #{release_path}/.rvmrc")
#     end
#   end

  task :copy_sync_scripts do
    on roles(:app) do
      execute("cd #{release_path}; cp -r script/sync_scripts/* ~/#{fetch(:stage)}_sync_scripts")
    end
  end

  after "deploy:update_code", "solr:symlink"

  namespace :solr do
    desc "start solr"
    task :start, :roles => :app, :except => { :no_release => true } do
      run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:start"
    end
    desc "stop solr"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:stop"
    end
    desc "reindex the whole database"
    task :reindex, :roles => :app do
      run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex"
    end
    desc "Symlink in-progress deployment to a shared Solr index"
    task :symlink, :except => { :no_release => true } do
      #创建solr所需要的目录
      run "cd #{deploy_to} && mkdir -p #{shared_path}/solr/data"
      run "cd #{deploy_to} && mkdir -p #{shared_path}/solr/pids"

      run "ln -s #{shared_path}/solr/data/ #{release_path}/solr/data"
      run "ln -s #{shared_path}/solr/pids/ #{release_path}/solr/pids"
    end
  end

  after :finishing, 'deploy:cleanup'
  #after :finishing, :copy_sync_scripts
  # after :finishing, 'deploy:spec_ruby_version'

end
