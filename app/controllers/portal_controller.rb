# encoding: utf-8

# author: depp.yu
# 网站首页（目前是这个，如有需要，以后可以修改)

class PortalController < BaseController
  
  skip_before_action :authenticate_user!
  
  # 系统首页
  # 参数：
  def index
    @user = User.new unless current_user
    
    @hot_brands = Brand.order("click_counter desc").limit(4)
    
    post_conditions = {_type: Post::TYPES.keys[1]}
    post_conditions.merge!({brand_id: params[:brand_id]}) if params[:brand_id]
    
    @posts  = Post.where(post_conditions).order("updated_at desc")                     
    @posts  = Post.where(_type: Post::TYPES.keys[1]).order('updated_at desc').limit(8)
    
    @posts_with_brands = @hot_brands.each_with_object({}) do |brand, ha|
                            posts = Post.where("_type = ? and brand_id = ?", Post::TYPES.keys[1], brand.id) \
                            .order("updated_at desc").limit(8)                                    
                            ha.merge!({brand.id => posts})
                            ha
                         end
    # 最新车源
    @newest_resouces = Post.where(_type: Post::TYPES.keys[0]).order('updated_at desc').limit(10)                     
                           
  end
  
  # 首页搜索
  # 参数：
  #   channel: 搜索入口
  #   key: 关键字
  def search
    case params[:channel]
    when 'all' then
      
    when 'brand' then
        
    end
  end
  
end


