# encoding: utf-8
# 验证码
class Api::ValidCodesController < Api::BaseController

  skip_before_filter :auth_user, only: [:index, :validate_code]
  
  before_action :is_registered, only: [:index]
  
  # 手机验证码获取
  #
  # Params:
  #   mobile:    [String] 手机号码
  #   type:     [Integer] 验证码使用类型(注册：0)
  # Return:
  #   status:    [Integer] 状态码(200)
  #   notice:    [String]  消息('success')
  #   code:      [String]  手机验证码
  # Error:
  #   status:    [Integer] 状态码(500)
  #   notice:    [String]  消息('failed')
  #   error_msg: [String]  错误信息
  def index
    raise Errors::InvaildVaildCodeError.new, t('error_msgs.mobile_blank_or_not_formatted') \
                                             unless is_legal?(params[:mobile], :mobile)

    valid_code = ValidCode.where(mobile: params[:mobile], _type: params[:type]).first

    if valid_code and valid_code.is_valid?
      valid_code.send_code
      render json: { status: 'success', code: valid_code.code }
    else
      valid_code = ValidCode.new(mobile: params[:mobile], _type: params[:type])

      if valid_code.save
        valid_code.send_code
        render json: { status: 'success', code: valid_code.code }
      else
        render json: { status: 'failure', error_msg: valid_code.errors.full_messages.join('\n') }
      end
    end
  rescue Errors::InvaildVaildCodeError => ex
    render json: { status: 'failure', error_msg: ex.message }
  end

  # 验证手机验证码是否有效
  # Params:
  #   mobile: [String] 手机号码
  #   valid_code: [String] 验证码
  # Return:
  #   status: [Integer] 状态码（200）
  #   notice: [String] 消息('success')
  # Error:
  #   status:    [Integer] 状态码(500)
  #   notice:    [String]  消息('failed')
  
  def validate_code
    raise Errors::ArgumentsError.new, t('error_msgs.arguments_errors') \
            unless is_legal?(params[:mobile], :mobile) and is_legal?(params[:valid_code], :code)
    valid_code = ValidCode.where(mobile: params[:mobile], code: params[:valid_code]).first

    json = if valid_code and valid_code.is_valid?
             { status: 200, notice: 'success' }
           else
             { status: 500, notice: 'failure' }
           end
    render json: json
  rescue Errors::ArgumentsError => error
    render json: { status: 500, notice: 'failed', error_msg: error.message }
  end

  private
  def is_legal?(str, type)
    case type
    when :mobile then
      str.present? and (str =~ /(\A1[3|4|5|8][0-9]{9}\z)/) == 0
    when :code then
      str.present? and (str =~ /(\A\w{6}\z)/) == 0
    else
      false
    end
  end
  
  def is_registered
    if params[:type].to_i == ValidCode::TYPES.keys[1]
      u = User.find_by(mobile: params[:mobile])
      render json: { status: 500 , notice: 'failed', error_msg: "该号码还未注册，请先注册"} and return if u.blank?
    end
  end

end
