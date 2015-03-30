# encoding: utf-8
# source 'https://rubygems.org'
source 'http://ruby.taobao.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# 支持js6语法包
gem 'sprockets', '~> 3.0.0.beta'
gem 'sprockets-es6', '~> 0.6.0'

# 图片处理 gem
gem 'carrierwave'
gem 'mini_magick'

# 用 devise 处理用户login
gem 'devise'

# authorization user
gem 'cancan'

gem 'httpclient'

# 导入导出
gem 'roo', '~> 1.13.2'
gem 'writeexcel', '~> 1.0.5'

gem 'kaminari'

gem 'acts_as_list'

# code formatter
# gem 'rubocop'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Deploy
gem 'rvm'

#gem 'rvm-capistrano'
gem 'capistrano','~> 3.3.0'
gem 'capistrano-ext'
gem 'capistrano-unicorn', :require => false
gem 'capistrano-rails'
gem 'capistrano-bundler'
gem 'capistrano-rvm'

group :production do
  gem 'unicorn-rails', '~> 2.2.0'
  gem 'unicorn'
  gem 'newrelic_rpm'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # gem 'rubocop', git: 'git@github.com:bbatsov/rubocop.git', require: false
  gem 'rspec-rails', '~> 3.0'
  gem 'pry-rails'

  # fixtures replacement
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner'
  gem 'capybara', '~> 2.3.0'
end

group :development do
  # A static analysis security vulnerability scanner
  gem 'brakeman', require: false
  # check N + 1 query
  gem 'bullet'
  # find the dead routes and actions
  gem 'traceroute'

  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'rack-mini-profiler', require: false
  # gem 'flamegraph' # 2.1 2.0 only
end

# simple admin
# gem 'rails_admin', git: "https://github.com/sferik/rails_admin.git", branch: 'master'

#api doc
# gem 'api_doc_generation', git: 'git@github.com:season/rails_api_doc_generation.git', branch: 'master'

# Plain Old Ruby Object
gem 'virtus'

# translate chinese to Pinyin
gem 'chinese_pinyin'

