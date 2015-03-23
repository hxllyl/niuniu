# encoding: utf-8
# 用户注册
class Api::RegistrationsController < Devise::RegistrationsController #Api::BaseController #
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # before_filter :configure_register_params, only: [:create]
  # skip_before_filter :auth_user, only: [:create]

  # 用户注册
  #
  # Params:
  #   user[mobile]:                 [String] 手机号
  #   user[password]:               [String] 密码
  #   user[password_confirmation]:  [String] 密码确认
  #   user[name]:                   [String] 用户名称
  #   user[company]:                [String] 公司名称
  #   user[area_id]:                [Integer]用户所在城市id
  #   user[role]:                   [String] 用户角色(app端注册用'normal')
  #   valid_code:                   [String] 手机验证码
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
    params.require(:user).permit!
    resource = User.new(params[:user])
    # build_resource
    # resource.skip_confirmation!
    if resource.save
      valid_code = ValidCode.find_by_mobile_and_code_and_status(resource[:mobile], params[:valid_code], 0)

      raise Errors::ValidCodeNotFoundError.new, t('exceps.not_found_valid_code') unless valid_code

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
