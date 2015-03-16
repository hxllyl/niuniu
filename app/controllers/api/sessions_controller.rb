# encoding: utf-8

class Api::SessionsController < Devise::SessionsController
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  def create
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    render json:  {
                    status:   200,
                    success:  true,
                    info:     "Logged in",
                    data:     {auth_token: current_user.authentication_token}
                  }
  end

  def destroy
    warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    current_user.update_column(:authentication_token, nil)
    render json:  {
                    status:   200,
                    success:  true,
                    info:     "Logged out",
                    data:     {}
                  }
  end

  def failure
    render json:  {
                    status:   401,
                    success:  false,
                    info:     "Login Failed",
                    data:     {}
                  }
  end

end
