# encoding: utf-8

class UserMessage < ActiveRecord::Base
  
  
  validates :user,  presence: true
  validates :message,  presence: true
    
  belongs_to :user, class_name: 'User'
  belongs_to :message, -> { where("messages._type = ?", Message::TYPES.keys[0])}, class_name: 'Message'

end