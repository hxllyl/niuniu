# encoding: utf-8
# 验证码
class Api::ValidCodesController < Api::BaseController

  skip_before_filter :auth_user, only: [:index]

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
                                             unless is_legal?params[:mobile]

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
        render json: { status: 'failed', error_msg: valid_code.errors.full_messages.join('\n') }
      end
    end
  rescue Errors::InvaildVaildCodeError => ex
    render json: { status: 'failed', error_msg: ex.message }
  end

  private
  def is_legal?(mobile)
    mobile.present? and (mobile =~ /(\A1[3|4|5|8][0-9]{9}\z)/) == 0
  end
end
