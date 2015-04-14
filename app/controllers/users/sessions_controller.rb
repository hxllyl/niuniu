# encoding: utf-8

class Users::SessionsController < Devise::SessionsController
  before_filter :configure_sign_in_params, only: [:create]
  # after_filter  :after_sign_out_path_for, only: [:destory]
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    if self.resource
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)

      if params[:remember_name]
        cookies[:user_name] = {
          value: params[:user][:mobile],
          expires: 1.month.from_now
        }
      else
        cookies[:user_name] = nil
      end

    else
      # Authentication fails, redirect the user to the root page
      flash[:error] = '用户名或密码错误！'
      redirect_to request.referrer || '/'
    end

  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # You can put the params you want to permit in the empty array.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:mobile, :password, :remember_me, :remember_name ) }
  end

  # sign in after redirect to
  def after_sign_in_path_for(resource)
    request.referrer || '/'
  end

  # configure redirect to viewer after devise destory
  def after_sign_out_path_for(resource_or_scope)
    '/'
  end

end
