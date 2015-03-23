# encoding: utf-8
# 用户注册
class Api::RegistrationsController < Devise::RegistrationsController #Api::BaseController #
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # 用户注册
  #
  # Params:
  #   mobile:       [String] 手机号
  #   password:     [String] 密码
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user_attrs and token
  # Error
  #  status: [Integer] 400
  #  notice: [String]  注册失败，请重新注册
  def create
    # curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST http://localhost:3000/api/v1/registrations -d "{\"user\":{\"mobile\":\"15899008877\",\"name\":\"evan\",\"password\":\"123456\",\"password_confirmation\":\"123456\"}}"

    build_resource
    resource.skip_confirmation!
    if resource.save
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
                      notice:   '注册失败，请重新注册'
                    }
    end
  end
end
