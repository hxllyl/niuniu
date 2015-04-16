# encoding: utf-8

class Token < ActiveRecord::Base
   
  # relations
  belongs_to :user, class_name: 'User'
  

  after_initialize :set_expired
  
  def set_expired
    expired_at = 7.days.from_now
  end
  
  def for_api
    {
      status: status,
      user_id: user_id,
      value: value,
      expired_at: expired_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end  
  
end
