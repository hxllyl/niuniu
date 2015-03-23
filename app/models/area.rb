# encoding: utf-8

class Area < ActiveRecord::Base
  
  #constants
  LEVELS = {
    province: 1,
    city: 2
  }
  
  has_many :users, class_name: 'User' # 和用户关联
  has_many :children, class_name: 'Area', foreign_key: :parent_id # 自关联
  belongs_to :parent, class_name: 'Area' # 自关联
  
  # scopes
  [:provinces, :cities].each { |a| scope a, -> { where(level: LEVELS[a.to_s.singularize.to_sym]) }}
  
  # instance_method
  #
  def as_api
    {
     id:       self.id,
     name:     self.name,
     level:    self.level
    }
  end
  
end