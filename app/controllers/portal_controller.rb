# encoding: utf-8

# author: depp.yu
# 网站首页（目前是这个，如有需要，以后可以修改）

class PortalController < BaseController
  skip_before_action :authenticate_user!
  
  # 系统首页
  # 参数：
  def index
    if current_user
      @sources, @posts = current_user.resources(:source), 
                         current_user.resources(:post) # 我的资源和寻车
      @tenders = current_user.tenders # 我的报价
      @followings = current_user.followings # 我的关注
    else
      @user = User.new
    end
    
    @posts  = Post.where(_type: Post::TYPES.keys[1]).order("updated_at desc")
                         
  end
  
end


