class Users::PasswordsController < Devise::PasswordsController
  
  before_filter :require_no_authentication, except: [:edit, :update]
  before_filter :assert_reset_token_passed, except: [:edit, :update]
  
  before_filter :configure_sign_in_params, only: [:update, :create]
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    
  end

  protected
  # You can put the params you want to permit in the empty array.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:current_user, :password, :password_confirmation ) }
  end

  def after_resetting_password_path_for(resource)
    #super(resource)
    request.referrer || '/'
  end
  
  def user_params
    params[:user].permit(:current_user, :password, :password_confirmation)
  end
  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
