# encoding: utf-8
require 'jpush'

module Concerns
  module MessageHandler
    extend ActiveSupport::Concern 
  
    def send_mobile_message(mobile, msg)
      corp_id, login_name, password = APP_CONFIG['qx_id'].to_s, APP_CONFIG['qx_login'].to_s, APP_CONFIG['qx_password'].to_s
                                                   
      clnt = HTTPClient.new
      service_url = "http://api.cosms.cn/sms/putMt/?msgFormat=2&corpId=#{corp_id}&loginName=#{login_name}&password=#{password}&Mobs=#{mobile}&msg=#{msg}&mtLevel=1&MD5str="
      json        = clnt.get_content(URI.encode(service_url), {}, { :Accept=> 'application/json' })
      status = json.split('\n').first
    
      logger.info status.to_s + status.class.to_s 
    end
    
    def jpush_message(j_msg, reg_ids)
      
      return if reg_ids.blank? or reg_ids.empty?
      j_msg = j_msg.truncate(72) if j_msg.length > 72
      
      app_key, master_secret = APP_CONFIG['app_key'], APP_CONFIG['master_secret']
      client ||= JPush::JPushClient.new(app_key, master_secret) 
      
      logger = Logger.new(STDOUT)
      
      options = {
        platform: JPush::Platform.all,
        audience: JPush::Audience.build(registration_id: reg_ids),
        options:  JPush::Options.build(apns_production: true),
        notification: JPush::Notification.new(alert: "#{j_msg}")
      }
      
      payload = JPush::PushPayload.new(options)
      
      result = client.sendPush(payload);
      logger.debug("Got result  " + result)
    end
    
  end
end