class Admin::BaseController < ApplicationController

  before_action :require_internal_staff
  layout 'admin'

  # TODO: add logic
  # Internal staff: salesman, normal_admin, super_admin
  def require_internal_staff
    
  end

  def require_normal_admin

  end

  def salesman?

  end

  def normal_admin?

  end

  def super_admin?

  end
  
end
