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
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    params_container = resource_name == :user ? user_params : params[resource_name]
    
    if resource.update_with_password(params_container)
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource){ render_with_scope :edit }
    end
  end

  protected
  # You can put the params you want to permit in the empty array.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:current_user, :password, :password_confirmation ) }
  end

  def after_update_path_for(resource)
    #super(resource)
    request.referrer || '/'
  end
  
  def user_params
    params[:user].permit(:current_password, :password, :password_confirmation)
  end
  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
