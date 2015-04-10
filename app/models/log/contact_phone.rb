# encoding: utf-8

class Log::ContactPhone < ActiveRecord::Base

  TYPES = {
    0 => '客服',
    1 => '用户'
  }

  validates :mobile, presence: true, uniqueness: true, format: { with:  /\A1[3|4|5|8][0-9]{9}\z/ }
  # validates :sender_id, presence: true
  validates :_type,  presence: true, inclusion: {in: TYPES.keys}

  belongs_to :sender, class_name: 'User' # 业务员

  def user
    User.find_by_mobile(mobile)
  end

end
