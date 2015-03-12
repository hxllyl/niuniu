# encoding: utf-8
class Post < ActiveRecord::Base
  
  # relations
  belongs_to :user, class_name: 'User'
end
