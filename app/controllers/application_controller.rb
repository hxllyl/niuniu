require 'forwardable'
require 'naught'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  extend Forwardable

  def_delegator ActiveSupport::Notifications, :instrument

  NullObject = Naught.build

  private

  def authenticate_user!
    if user_signed_in?
      return true
    else
      flash[:notice] = "请您先登陆,谢谢。"
      redirect_to root_path
    end
  end

end
