class Admin::BaseController < ApplicationController

  before_action :require_internal_staff
  layout 'admin'

  # TODO: add logic
  # Internal staff: salesman, normal_admin, super_admin
  def require_internal_staff
    
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
