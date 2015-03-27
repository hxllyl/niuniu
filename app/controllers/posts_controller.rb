# encoding: utf-8

require_relative '../../app/services/search_resource'
require_relative '../../app/services/list_resources'

class PostsController < ApplicationController

  def index
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @_type      = params[:_type]
    @standards  = Standard.all
    @brands     = Brand.order(click_counter: :desc).limit(20)
    @car_models = CarModel.order(click_counter: :desc).limit(40)

    # posts   = Post.includes(:base_car, :post_photos, :standard, :brand).where(_type: params[:_type]).order(updated_at: :desc).select(:user_id).distinct
    posts   = Post.includes(:base_car, :post_photos, :standard, :brand).where(_type: params[:_type]).order(updated_at: :desc).group_by(&:user_id).collect{|k, v| v.first}
    @posts  =  Kaminari.paginate_array(posts).page(params[:page]).per(10)
  end

  # 市场资源点击品牌进入资源列表页
  def resources_list
    @rs = ListResources.new(params)

    @resources = if @rs.car_model.present?
                   @rs.car_model.posts.includes(:base_car, :user).resources
                 else
                   Post.includes(:base_car, :user).resources.with_brand(@rs.brand)
                 end

  rescue => e
    render json: {status: :not_ok, msg: e.message}
  end

  # 寻车信息点击品牌进入寻车列表页
  def needs_list
    @rs = SearchResource.new(params)
    @needs = if @rs.car_model.present?
               @rs.car_model.posts.needs
             elsif @rs.brand.present?
               Post.needs.with_brand(@rs.brand)
             elsif @rs.standard.present?
               Post.with_standard(@rs.standard).needs
             else
               Post.needs
             end
  # rescue => e
  #   render json: {status: :not_ok, msg: e.message}
  end

  def show
    @post     = Post.find_by_id(params[:id])
    @someone  = @post.user
    @follows  = current_user.followings & @someone.followers if current_user
  end

  def user_list
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    # params[:user_id] 某用户
    @_type = params[:_type]
    @someone = User.find_by_id(params[:user_id])
    @posts = Post.where(user_id: params[:user_id], _type: params[:type]).order(updated_at: :desc).page(params[:page]).per(10)
  end

  # 资源表 首页中间最底部的链接
  def user_resources_list
    @posts = Post.all.page(params[:page]).per(10)
  end

end
