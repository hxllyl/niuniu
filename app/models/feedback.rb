# encoding: utf-8

class Feedback < Message
  
  validates :sender, presence: true
  validates :receiver, presence: true
  
  # belongs_to :sender, class_name: 'User'
  # belongs_to :receiver, class_name: 'User'
  
  after_initialize :set_type
  
  def set_type
    _type = TYPES.keys[1]
  end
end