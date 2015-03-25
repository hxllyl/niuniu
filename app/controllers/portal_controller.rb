# encoding: utf-8

# author: depp.yu
# 网站首页（目前是这个，如有需要，以后可以修改)

class PortalController < BaseController

  skip_before_action :authenticate_user!

  # 系统首页
  # 参数：
  def index
    @user = User.new unless current_user

    # 最热品牌，寻车4个，资源8个
    @hot_brands = Brand.includes(:car_photo).order(click_counter: :desc).limit(8)

    # 寻车列表
    @needs      = Post.needs.includes(:user, :car_model, :standard, brand: [:car_photo]).order(updated_at: :desc).limit(8)

    # 四个品牌对就的寻车列表
    @posts_with_brands = @hot_brands[0..3].each_with_object({}) do |brand, ha|
                            posts = brand.posts.resources.order(updated_at: :desc).limit(8)
                            ha.merge!({brand.id => posts})
                            ha
                         end

    # 最热车源
    @hot_resources = Post.resources.order(sys_set_count: :desc).limit(8)

    # 最新车源
    newest_resouces   = Post.resources.includes(:user, :brand, :car_model).order(updated_at: :desc).group_by(&:user_id)
    @newest_resouces  = []

    newest_resouces.each_with_index do |ele, i|
      break if i == 10
      @newest_resouces << ele.last.first
    end

    # 资源表
    user_resources = Post.resources.includes(:user, :brand).order(updated_at: :desc).group_by(&:user_id)

    @user_resources  = []

    user_resources.each_with_index do |ele, i|
      break if i == 10
      @user_resources << {name: ele.last.first.user_name, id: ele.last.first.user_id, area: ele.last.first.user.area_name, time: ele.last.first.publish_time, brands: ele.last.map(&:brand_name).uniq.join(' ')}
    end
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


