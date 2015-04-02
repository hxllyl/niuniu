# encoding: utf-8

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
    
  end
end