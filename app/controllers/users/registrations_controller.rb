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


  ValidCode.transaction do
    if resource.save
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

        valid_code = ValidCode.where(mobile: resource[:mobile], code: params[:valid_code], \
                                    status: ValidCode::STATUS.keys[0]).first
        raise Errors::ValidCodeNotFoundError.new, t('exceps.not_found_valid_code') if valid_code.blank?
        valid_code.update(status: ValidCode::STATUS.keys[1])

        log = Log::ContactPhone.where(mobile: resource[:mobile]).first_or_initialize
        log.is_register = true
        log._type = 1
        log.save
      end
    else
      clean_up_passwords resource
      # set_minimum_password_length
      # respond_with resource
      redirect_to request.referrer || '/'
    end
  end

  rescue Errors::ValidCodeNotFoundError => vc_error
    flash[:error] = vc_error and redirect_to request.referrer || '/'
  rescue ActiveModel::Errors => ex
    flash[:error] = resource.errors.full_messages.join('\n') and redirect_to request.referrer || '/'
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
                                                            :email, :mobile, :role, :company,
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
