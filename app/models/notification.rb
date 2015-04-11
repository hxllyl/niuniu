# encoding: utf-8

# author: depp.yu

class Notification < ActiveRecord::Base
  
  STATUS = {
    0 => '未读',
    1 => '已读',
    -1 => '删除'
  }
  
  # ralations
  belongs_to :user, class_name: 'User'
  
  # scopes
  scope :unreads, -> { where(status: STATUS.keys[0]) }
  scope :readeds, -> { where(status: STATUS.keys[1]) }
  
end
