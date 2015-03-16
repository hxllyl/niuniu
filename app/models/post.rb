# encoding: utf-8
class Post < ActiveRecord::Base
  
  # constants
  TYPES = {
    1 => '资源',
    2 => '寻车'
  }
  
  # relations
  belongs_to :user, class_name: 'User'
  has_many :tenders, -> {where(_type: TYPES[2])}, class_name: 'Tender'
end
