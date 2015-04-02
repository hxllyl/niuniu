class Admin::BaseController < ApplicationController

  before_action :require_admin
  layout 'admin'

  # TODO: add logic
  def require_admin

  end

  def salesman?

  end

  def normal_admin?

  end

  def super_admin?

  end
  
end
