# encoding: utf-8

require 'forwardable'
require 'naught'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  extend Forwardable

  before_action :redirect_to_mobile_page, if: proc { request.url !~ /mobile_displays/ }

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

  def auth_my_self
    if current_user.id == params[:user_id].to_i
      return true
    else
      flash[:notice] = "您无权访问此页面"
      redirect_to root_path
    end
  end

  def auth_staff
    if current_user.class == Staff && current_user.role != 'staff'
      @someone = User.find_by_id(params[:user_id])
      return
    else
      flash[:notice] = "您无权访问此页面"
      redirect_to root_path
    end
  end


  # 用于手机、移动页面的渲染
  # if browser.mobile?
  #   request.variant = :tablet
  # end

  def redirect_to_mobile_page
    if browser.mobile? && !params[:controller].include?('api')
      redirect_to mobile_displays_path # if request.request_uri !~ /mobile_displays/
    end
  end

end
