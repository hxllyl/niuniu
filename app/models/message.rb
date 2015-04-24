# encoding: utf-8

require 'concerns/message_handler'

class Message < ActiveRecord::Base
  
  include Concerns::MessageHandler
  
  STATUS = {
    0 => '未读',
    1 => '已读'
  }
  # enum status: [:read, :unread]
  
  TYPES = {
    0 => '系统',
    1 => '用户反馈',
    2 => '新增报价',
    3 => '报价完成',
    4 => '寻车完成'
  }
  
  self.inheritance_column = :mask
  
  # 接收组：all - 所有用户
  # http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum receiver_group: [ :all_users ]

  validates :content, presence: true
  validates :_type, inclusion: { in: TYPES.keys }
  validates :status, inclusion: { in: STATUS.keys }
  
  
  
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  
  has_many :user_messages, class_name: 'UserMessage', dependent: :nullify
  has_many :users, through: :user_messages, source: :user
  
  # belongs_to :staff, -> { where(_type: TYPES.keys[1])} , class_name: 'Staff'
  
  def for_api
    {
      title: title,
      content: content,
      status: status,
      created_at: created_at,
      _type: _type
    }
  end
  
  def self.make_system_message(message, user, type)
    Message.create(_type: type, receiver: user, content: message)
  end
  
  after_create :push_message

  def real_receiver_users
    if receiver_group && receiver_group.all_users?
      users = User.all
    end
  end
  
  def push_message
    if _type != TYPES.keys[1]
      if self.receiver
        
        Thread.new {
          sleep 0.1
          jpush_message(content, ActiveDevice.push_list(receiver).pluck(:register_id))
        }
      else
        if _type == TYPES.keys[0]
            Thread.new {
              users = User.valid_user
              self.users << users
              
              sleep 0.1
              jpush_message(content, ActiveDevice.active.pluck(:register_id))
            }
            
        end
      end
    end
  end
  
end
