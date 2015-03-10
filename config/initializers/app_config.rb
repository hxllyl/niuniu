# encoding: utf-8

# author: depp.yu

require 'yaml'

unless defined? APP_CONFIG
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
end