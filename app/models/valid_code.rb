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
  
  CODE_SIZE = 6
  
  # validates
  validates :code, presence: true, uniqueness: true, format: { with: /\A\w{6}\z/ }
  validates :mobile, presence: true, format: { with:  /\A1(3|4|5|8|)\d{9}\z/ }, uniqueness: { if: Proc.new{ |code| code._type == TYPES.keys[0] } }
  validates :status, inclusion: { in: STATUS.keys }
  
  # scopes
  scope :actives, ->{ where(status: STATUS.keys[0]) }
  
  # instance_method
  def is_valid?
    self.status == STATUS.keys[0]
  end

  # 对手机发送消息
  before_create :send_code
  def send_code
    raise Errors::InvaildVaildCodeError.new, "#{self.code}已经被使用过" unless self.is_valid?
    
    flag = generate_notify(
                           APP_CONFIG['qx_id'].to_s, 
                           APP_CONFIG['qx_login'].to_s, 
                           APP_CONFIG['qx_password'].to_s,
                           self.mobile, 
                           APP_CONFIG['qx_tip'] + self.code
                           )
    return unless flag                       
  end

  # 设置默认值
  after_initialize :set_defaults
  def set_defaults
    self.status ||= STATUS.keys[0]
    self.code ||= rand(36**CODE_SIZE).to_s(36)
  end
  
  private
  def generate_notify(corp_id, login_name, password, mobile, msg)
    clnt = HTTPClient.new
    service_url = "http://api.cosms.cn/sms/putMt/?msgFormat=2&corpId=#{corp_id}&loginName=#{login_name}&password=#{password}&Mobs=#{mobile}&msg=#{msg}&mtLevel=1&MD5str="
    json        = clnt.get_content(URI.encode(service_url), {}, { :Accept=> 'application/json' })
    status = json.split('\n').first
    
    logger.info status.to_s + status.class.to_s 
    true if status == '100'
  end
  
end
