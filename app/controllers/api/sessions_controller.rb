# encoding: utf-8
# 用户登陆、注销
class Api::SessionsController < Devise::SessionsController #Api::BaseController #
  skip_before_filter :verify_authenticity_token
  skip_before_action :verify_signed_out_user
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
    
    current_user.token.update(expired_at: 7.days.from_now)
    
    respond_to do |format| 
      format.json {
        render json:  {
                        status:   200,
                        notice:   'success',
                        data:     { token: current_user.token.for_api }
                      }
      }
    end
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

    u = Token.find_by_value(params[:token]).user
    sign_out(u)
      render json:  {
                    status:   200,
                    notice: 'success',
                    data:     {}
                  }
  end

  def failure
    render json:  {
                    status:   400,
                    notice:   'failed',
                    data:     {}
                  }
  end

end
