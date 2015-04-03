class Admin::BaseController < ApplicationController

  before_action :require_staff
  layout 'admin'

  def current_staff
    # TODO: Fake current_staff, need add the real logic
    @current_staff ||= User.first
  end

  # TODO: add logic
  # Internal staff: salesman, normal_admin, super_admin
  def require_staff
    if !current_staff
      redirect_to root_path, alert: '很抱歉，您没有权限' and return
    end
  end

  def require_normal_admin

  end

  helper_method :salesman?
  def salesman?

  end

  helper_method :normal_admin?
  def normal_admin?

  end

  helper_method :super_admin?
  def super_admin?

  end
  
end
