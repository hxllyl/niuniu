# encoding: utf-8
# 用户注册
class Api::RegistrationsController < Devise::RegistrationsController #Api::BaseController #
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # before_filter :configure_register_params, only: [:create]
  skip_before_filter :auth_user, only: [:create]

  # 用户注册
  #
  # Params:
  #   mobile:       [String] 手机号
  #   password:     [String] 密码
  #   password_confirmation: [String] 密码确认
  #   name: [String] 用户名称
  #   company: [String] 公司名称
  #   area_id: [String] 用户所在城市id
  #   valid_code: [String] 手机验证码
  #   role: [String] 用户角色(app端注册用'normal')
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user_attrs and token
  # Error
  #   status: [Integer] 400
  #   notice: [String]  注册失败，请重新注册
  # ValidCodeError:
  #   status: [Integer] 500
  #   notice: [String] 手机号码为空或者手机号码不正确
  # ActiveModelError
  #   status: [Integer] 500
  #   notice: [String] 用户保存的字段验证错误信息
  def create
    # curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST http://localhost:3000/api/v1/registrations -d "{\"user\":{\"mobile\":\"15899008877\",\"name\":\"evan\",\"password\":\"123456\",\"password_confirmation\":\"123456\"}}"
    build_resource

    if resource.save
      valid_code = ValidCode.where(mobile: resource[:mobile], code: params[:valid_code],
                                   status: ValidCode::STATUS.keys[0]).first
      raise Errors::ValidCodeNotFoundError.new, t('exceps.not_found_valid_code') if valid_code.blank?
      valid_code.update(status: ValidCode::STATUS.keys[1])

      sign_in resource
      render json:  {
                      status:   200,
                      notice:   'success',
                      data:     {
                                  user:  resource,
                                  token: current_user.token
                                }
                    }
    else
      render json:  {
                      status:   400,
                      notice:   resource.errors
                    }
    end
  rescue Errors::ValidCodeNotFoundError => vc_error
    render json: {
                   status: 500,
                   notice: vc_error.message
                 }
 #  rescue ActiveModel::Errors => ex
 #    render json: {
 #                   status: 500,
 #                   notice: resource.errors.full_messages.join('\n')
 #                 }
  end
end
