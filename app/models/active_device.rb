# encoding: utf-8

class ActiveDevice < ActiveRecord::Base
  
  validates :user_id, presence: true
  validates :register_id, presence: true, uniqueness: true
  
  belongs_to :user, class_name: 'User'
  
  scope :push_list, ->(user){ where(user: user, active: true) }
  
  scope :active, ->{where('active = ?', true)}
end
