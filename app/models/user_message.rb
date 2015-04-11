# encoding: utf-8

class UserMessage < ActiveRecord::Base
  
  STATUS = {
    0 => '未读',
    1 => '已读'
  }
  
  validates :user,  presence: true
  validates :message,  presence: true
    
  belongs_to :user, class_name: 'User'
  belongs_to :message, -> { where("messages._type = ?", Message::TYPES.keys[0])}, class_name: 'Message'

  scope :unread, -> { where("status = 0") }
  
  def for_api
    {
      title: message.try(:title),
      content: message.try(:content),
      status: status,
      created_at: created_at,
      _type: message.try(:_type)
    }
  end
  
end