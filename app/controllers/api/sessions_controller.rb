# encoding: utf-8
# 用户登陆、注销
class Api::SessionsController < Devise::SessionsController #Api::BaseController #
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # 用户登陆
  #
  # Params:
  #   user[mobile]:       [String] 手机号
  #   user[password]:     [String] 密码
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [Hash]    {token: token}
  # Error
  #  status: [Integer] 400
  #  notice: [String]  请输入正确的帐号密码
  def create
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")

    render json:  {
                    status:   200,
                    notice:   'success',
                    data:     {
                                token:      current_user.token,
                                car_infos:  Standard.all.map(&:to_hash),
                                updated_at: [Standard.all.map(&:updated_at), Brand.all.map(&:updated_at), BaseCar.all.map(&:updated_at)].flatten.max
                              }
                  }
  end

  # 用户注销
  #
  # Params:
  #   token:        [String] valid token
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String] success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重试
  def destroy
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    current_user.token.update_attributes(value: nil)
    render json:  {
                    status:   true,
                    data:     {}
                  }
  end

  def failure
    render json:  {
                    status:   false,
                    data:     {}
                  }
  end

end
