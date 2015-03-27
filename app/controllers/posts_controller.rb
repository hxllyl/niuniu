# encoding: utf-8

require_relative '../../app/services/search_resource'

class PostsController < ApplicationController

  def index
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @_type = params[:_type]
    @posts = Post.includes(:base_car, :post_photos, :standard).where(_type: params[:_type]).order(updated_at: :desc).page(params[:page]).per(10)
  end

  # 市场资源点击品牌进入资源列表页
  def resources_list
    rs = SearchResource.new(params)
    car_model = rs.car_model
    @brand = rs.brand
    @standards = rs.standards

    # LESLIE: 这个地方需根据 _type 决定用 resources 还是 needs
    if car_model.present?
      @resources = car_model.posts.includes(:base_car, :user).resources
    else
      @resources = Post.includes(:base_car, :user).resources.with_brand(@brand)
    end

  rescue => e
    render json: {status: :not_ok, msg: e.message}
  end

  # 寻车信息点击品牌进入寻车列表页
  def needs_list
    rs = SearchResource.new(params)
    car_model = rs.car_model
    @brand = rs.brand || Brand.first
    @standards = Standard.where(id: @brand.standard_ids)

    # LESLIE: 这个地方需根据 _type 决定用 resources 还是 needs
    if car_model.present?
      @needs = car_model.posts.needs
    else
      @needs = Post.needs.with_brand(@brand)
    end

  rescue => e
    render json: {status: :not_ok, msg: e.message}
  end

  def show
    @post  = Post.find_by_id(params[:id])
    @someone  = @post.user
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
