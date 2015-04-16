# encoding: utf-8

class Token < ActiveRecord::Base
   
  # relations
  belongs_to :user, class_name: 'User'
    
  def for_api
    {
      status: status,
      user_id: user_id,
      value: value,
      expired_at: expired_at.strftime("%Y-%m-%d %H:%M:%S")
    }
  end  
  
end
