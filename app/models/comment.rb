# encoding: utf-8
class Comment < ActiveRecord::Base
  # validates
  
  # relations
  belongs_to :user, class_name: 'User'
end
