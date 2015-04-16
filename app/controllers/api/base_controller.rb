# encoding: utf-8

class Api::BaseController < ApplicationController
  before_filter :auth_user

  layout :false

  protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token

  def auth_user
    @token = Token.find_by_value(params[:token])

    raise 'not found valid token' unless @token

    @user = User.find_by_id(@token.user_id)

    raise 'not found valid user' unless @user

    raise '您的身份已失效' unless @user.valid?

    rescue => e
    render json: {status: false, error: e.message}
  end


end
