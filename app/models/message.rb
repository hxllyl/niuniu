# encoding: utf-8

class Message < ActiveRecord::Base
  
  STATUS = {
    0 => '未读',
    1 => '已读'
  }
  
  TYPES = {
    0 => '系统',
    1 => '用户反馈'
  }
  
  validates :content, presence: true
  validates :_type, inclusion: { in: TYPES.keys }
  validates :status, inclusion: { in: STATUS.keys }
  
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  
  belongs_to :staff, -> { where(_type: TYPES.keys[1])} , class_name: 'Staff'
  
  def for_api
    {
      title: title,
      content: content,
      status: status,
      _type: _type
    }
  end
end
