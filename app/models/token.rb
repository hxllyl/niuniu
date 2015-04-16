# encoding: utf-8

class Token < ActiveRecord::Base
   
  # relations
  belongs_to :user, class_name: 'User'
  

  after_initialize :set_expired
  
  def set_expired
    expired_at = 7.days.from_now
  end
    
end
