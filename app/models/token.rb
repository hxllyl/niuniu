# encoding: utf-8

class Token < ActiveRecord::Base
  
  # relations
  belongs_to :user, class_name: 'User'
end
