# encoding: utf-8

# author: depp.yu
# 网站首页（目前是这个，如有需要，以后可以修改）

class PortalController < BaseController
  skip_before_action :authenticate_user!
  
  def index
  
  end
end
