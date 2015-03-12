# encoding: utf-8

# author: depp.yu

require 'yaml'

APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
