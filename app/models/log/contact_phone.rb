# encoding: utf-8

class Log::ContactPhone < ActiveRecord::Base
  
  TYPES = {
    0 => '客服',
    1 => '用户'
  }
  
  validates :mobile, presence: true, presence: true, format: { with:  /\A1[3|4|5|8][0-9]{9}\z/ }
  validates :sender, presence: true
  validates :_type,  presence: true, inclusion: {in: TYPES.keys}

end
