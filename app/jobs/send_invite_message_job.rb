# encoding: utf-8
require 'concerns/message_handler'

class SendInviteMessageJob < ActiveJob::Base
  
  include Concerns::MessageHandler   
  
  def perform(user, mobile)
    unless mobile.present? and (mobile =~ /(\A1[3|4|5|7|8][0-9]{9}\z)/) == 0
      Rails::logger.info ("#{Time.now}----#{mobile},发送失败")
    else
      msg =<<-EOF
      您的朋友#{user.name}，邀请您加入牛牛汽车大家庭! 您的汽车生意圈！我们的网站：#{APP_CONFIG['host']}
      EOF
      
      send_mobile_message(mobile, msg)
    end
  end
end
