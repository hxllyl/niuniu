class Users::SessionsController < Devise::SessionsController
  before_filter :configure_sign_in_params, only: [:create]
  # after_filter  :after_sign_out_path_for, only: [:destory]
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    if params[:remember_name]
      cookies[:user_name] = {
        value: params[:user][:mobile],
        expires: 1.month.from_now
      }
    else
      cookies[:user_name] = nil
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

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
    new_user_session_path
  end
   
end
