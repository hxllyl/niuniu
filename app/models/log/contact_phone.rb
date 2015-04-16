# encoding: utf-8

class Log::ContactPhone < ActiveRecord::Base

  TYPES = {
    0 => '客服',
    1 => '用户'
  }

  validates :mobile, presence: true, uniqueness: true, format: { with:  /\A1[3|4|5|8][0-9]{9}\z/ }
  # validates :sender_id, presence: true
  validates :_type,  presence: true, inclusion: {in: TYPES.keys}
  
  belongs_to :promoter, class_name: 'User'

  belongs_to :sender, class_name: 'Staff' 
  belongs_to :reg_admin, class_name: 'Staff' #代注册的管理员

  def user
    User.find_by_mobile(mobile)
  end

  def contacted?
    _type == 0 && sender_id
  end

end
