# encoding: utf-8
# 通讯录
class Api::PhoneListsController < Api::BaseController

  respond_to :json

  # 通讯录用户匹配系统用户
  #
  # Params:
  #   token:        [String] 用户token
  #   contacts[]:     [Array]  通讯录用户，具体格式：contacts: [
  #                                                         {name: name_1, mobile: '13112345678'},
  #                                                         {name: name_2, mobile: '15112345678'}
  #                                                        ]
  # Return:
  #   status: 200
  #   notice: success
  #   datas:  返回数据 {"status" : 200, "notice" : "success", "datas": [{name: '', mobile: '', user_id: '', is_following: }]
  #
  # Error:
  #   status: 500
  #   notice: failed
  #   error_msg: 错误消息

  def contact_list
    raise '请上传通讯录用户' if params[:contacts].blank? or params[:contacts].empty?

    datas = []

    params[:contacts].each_with_object({}) { |contact, hash|
      mobile = contact['mobile']
      u = User.find_by(mobile: mobile)
      hash = if u
              log = Log::ContactPhone.find_by(promoter: @user, mobile: mobile, _type:  Log::ContactPhone::TYPES.keys[1])
              {user_id: u.id, is_following: @user.following?(u), is_invite: log.present?}
             else
              {user_id: '', is_following: false, is_invite: false}
             end
      datas << contact.merge!(hash)
    }
    render json: { status: 200, notice: 'success', datas: datas}
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message}
  end

  # 发送邀请短信
  #
  # Params:
  #   token:      [String]  用户token
  #   mobile:     [String]  手机号码
  #
  # Return:
  #   status: 200
  #   notice: success
  #
  # Error:
  #   status: 500
  #   notice: failed
  #   error_msg: 错误信息

  def send_invite_message
    raise '手机号码不正确' if params[:mobile].blank? and (params[:mobile] =~ /(\A1[3|4|5|8][0-9]{9}\z)/) == 0

    mobile = params[:mobile]
    
    SendInviteMessageJob.perform_later(@user, mobile)
    
    payload = {
      promoter: @user, 
      mobile: mobile,
      _type:  Log::ContactPhone::TYPES.keys[1],
      last_contact_at: Time.now
    }
    
    instrument 'contact_phone.send_invite_message', payload do  
      render json: { status: 200, notice: 'success'}
    end
    
  rescue => ex
    render json: { status: 500, notice: 'failure', error_msg: ex.message}
  end

end
