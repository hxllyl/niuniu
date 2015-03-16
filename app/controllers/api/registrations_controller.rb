# encoding: utf-8
class Api::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    build_resource
    resource.skip_confirmation!
    if resource.save
      sign_in resource
      render json:  {
                      status:   200,
                      success:  true,
                      info:     'Registered',
                      data:     {
                                  user:       resource,
                                  auth_token: current_user.authentication_token
                                }
                    }
    else
      render json:  {
                      status:   :unprocessable_entity,
                      success:  false,
                      info:     resource.errors,
                      data:     {}
                    }
    end
  end

end
