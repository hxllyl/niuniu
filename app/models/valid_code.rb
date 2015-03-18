# encoding: utf-8

# author: depp.yu

class ValidCode < ActiveRecord::Base
  
  # constants
  STATUS = {
    0 => '未使用',
    1 => '已使用'
  }
  
  # 验证码的类型 目前只有一个
  TYPES = {
    0 => '注册'
  }
  
  # validates
  validates :code, presence: true, format: { with: /\A\w{6}\z/ }
  validates :mobile, presence: true, format: { with:  /\A1(3|4|5|8|)\d{9}\z/ }
  validates :status, inclusion: { in: ::STATUS.keys }
  
  # instance_method
  def is_invalid?
    self.status == STATUS.keys[1]
  end
  
  # 对手机发送消息
  after_create :send_code
  def send_code
    raise (InvaildVaildCodeError, "#{code}已经被使用过") if self.is_invalid?
    
    corp_id, login_name, password = APP_CONFIG['qx_id'], APP_CONFIG['qx_login'], APP_CONFIG['qx_password']
    msg  = APP_CONFIG['qx_tip'] + "#{self.code}"
    clnt = HTTPClient.new
    service_url = "http://api.cosms.cn/sms/putMt/?msgFormat=2&corpId=#{corp_id}&loginName=#{login_name}
                   &password=#{password}&Mobs=#{self.mobile}&msg=#{msg}&mtLevel=1&MD5str="
    json        = clnt.get_content(URI.encode(send_url), {}, { :Accept=> 'application/json' })
    
    logger.info "*" * 10
    logger.info json
    logger.info "*" * 10
    json                      
  end
  
  # 设置默认值
  after_initialize :set_defaults
  def set_defaults
    self.status ||= STATUS.keys[0]
  end
  
end
