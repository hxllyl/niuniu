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
    posts   = Post.includes(:base_car, :post_photos, :standard, :brand).where(_type: params[:_type]).order(updated_at: :desc).group_by(&:user_id).collect{|k, v| v.first}
    @posts  =  Kaminari.paginate_array(posts).page(params[:page]).per(10)
  end

  # 市场资源点击品牌进入资源列表页
  # params: st=1&br=1&cm=1&bc=1&oc=xx&ic=xx&rt=xx
  def resources_list
    logger.info "*" * 100
    logger.info params
    params.delete(:action)
    params.delete(:controller)

    @q_json = params
    logger.info @q_json
    logger.info "*" * 100
    @standards  = Standard.all
    @standard   = Standard.find_by_id(params[:st])

    @brands     = @standard ? @standard.brands.valid : Brand.valid
    @brand      = Brand.find_by_id(params[:br])

    if params[:st] && params[:br]
      @car_models = CarModel.where(standard_id: @standard.id, brand_id: @brand.id).valid
      @car_model  = CarModel.find_by_id(params[:cm])
    else
      @car_models = []
      @car_model  = nil
    end
    if params[:st] && params[:br] && params[:cm]
      @base_cars  = @car_model.base_cars.valid
      @base_car   = BaseCar.find_by_id(params[:bc])
    else
      @base_cars  = []
      @base_car   = nil
    end
    if params[:st] && params[:br] && params[:cm] && params[:bc]
      conds = {}
      conds[:outer_color]   = params[:oc]    if params[:oc]
      conds[:inner_color]   = params[:ic]    if params[:ic]
      conds[:resource_type] = params[:rt]    if params[:rt]

      @posts = @base_car.posts.resources.where(conds).order(updated_at: :desc).page(params[:page]).per(10)
    end
  # rescue => e
  #   render json: {status: :not_ok, msg: e.message}
  end

  def get_resources
    @standards  = Standard.all
    @standard   = Standard.find_by_id(params[:post_standard_id])
    @standard   = Standard.find_by_id(params[:standard_id])   unless @standard

    @brands     = @standard ? @standard.brands : Brand.all.valid
    @brand      = Brand.find_by_id(params[:post_brand_id])
    @brand      = Brand.find_by_id(params[:brand_id])         unless @brand

    @car_models = @standard && @brand ? CarModel.where(standard_id: @standard.id, brand_id: @brand.id) : []
    @car_model  = CarModel.find_by_id(params[:post_car_model_id])
    @car_model  = CarModel.find_by_id(params[:car_model_id])  unless @car_model

    @base_cars  = @car_model ? @car_model.base_cars : []
    @base_car   = BaseCar.find_by_id(params[:post_base_car_id])
    @base_car   = BaseCar.find_by_id(params[:base_car_id])    unless @base_car

    conds = {}
    conds[:outer_color]   = params[:outer_color]    if params[:outer_color]
    conds[:inner_color]   = params[:inner_color]    if params[:inner_color]
    conds[:resource_type] = params[:resource_type]  if params[:resource_type]

    @posts = @base_car ? @base_car.posts.resources.where(conds).order(updated_at: :desc).page(params[:page]).per(10) : nil

    render partial: 'resources_infos'
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
    @post     = Post.includes(:comments).find_by_id(params[:id])
    @someone  = @post.user
    @follows  = current_user.followings & @someone.followers if current_user
  end

  def user_list
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    # params[:user_id] 某用户
    @_type = params[:_type]
    @someone = User.find_by_id(params[:user_id])
    @posts = Post.where(user_id: params[:user_id], _type: params[:type]).order(updated_at: :desc).page(params[:page]).per(10)
    @follows  = current_user.followings & @someone.followers if current_user
  end

  # 资源表 首页中间最底部的链接
  def user_resources_list
    @users = User.where("id" => Post.resources.map(&:user_id)).page(params[:page]).per(10)
  end

end
