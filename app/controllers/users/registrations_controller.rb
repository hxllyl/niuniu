class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]
  
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
   #super
   build_resource(sign_up_params)

   resource.save
   yield resource if block_given?
   if resource.persisted?
     if resource.active_for_authentication?
       set_flash_message :notice, :signed_up if is_flashing_format?
       sign_up(resource_name, resource)
       respond_with resource, location: after_sign_up_path_for(resource)
     else
       set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
       expire_data_after_sign_in!
       respond_with resource, location: after_inactive_sign_up_path_for(resource)
     end
     valid_code = ValidCode.find_by(mobile: resource[:mobile], status: ValidCode::STATUS.keys[0])
     valid_code.update(status: ValidCode::STATUS.keys[1])
   else
     clean_up_passwords resource
     # set_minimum_password_length
     # respond_with resource
     redirect_to request.referrer || '/'
   end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected
  
  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :mobile, :role, :company, :area_id) }
  # end

  # You can put the params you want to permit in the empty array.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:password, :password_confirmation, :name, 
                                                            :email, :mobile, :role, :company, :role, 
                                                            :area_id )
                                             }
  end

  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    request.referer || '/'
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  
end
