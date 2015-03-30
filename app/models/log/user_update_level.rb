# encoding: utf-8

class Log::UserUpdateLevel < ActiveRecord::Base
  
  STATUS = {
    0 => '待审核',
    1 => '审核通过',
    2 => '审核不同'
  }
  
  belongs_to :user, class_name: 'User'
  belongs_to :operator, class_name: 'Staff'
  
  def show_photos_with_level
    types = case end_level
            when User::LEVELS.keys[1] then
              ['identity', 'hand_id']
            when User::LEVELS.keys[2] then
              ['license']
            when User::LEVELS.keys[3] then
              ['visiting', 'room_outer', 'room_inner', 'license']
            else 
              ['visiting', 'room_outer', 'room_inner']
            end
    photos = users.photos.where('_type in (?)', types)        
  end
  
end
