# encoding: utf-8

class Area < ActiveRecord::Base
  
  #constants
  LEVELS = {
    province: 1,
    city: 2
  }
  
  has_many :users, class_name: 'User' # 和用户关联
  has_many :children, class_name: 'Area' # 自关联
  belongs_to :parent, class_name: 'Area' # 自关联
  
  # instance_method
end