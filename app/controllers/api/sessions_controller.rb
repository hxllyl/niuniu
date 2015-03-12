# encoding: utf-8

class Api::SessionController < Devise::SessionsController

  # 用户登录
  #
  # Params:
  #   mobile:       [String] 存档键
  #   password:     [String] 存档值
  #
  # Return:
  #   success: [JSON] {:status=>true}
  #   fail:    [JSON] {:status=>false, :error=> 1000}
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
  end

end
