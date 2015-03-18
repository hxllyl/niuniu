# encoding: utf-8

class PostsController < ApplicationController

  def index
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @_type = params[:_type]
    @posts = Post.where(_type: params[:_type])
  end

  # 资源列表点击品牌进入资源列表页
  def resources_list

  end

  def show
    @_type = params[:_type]
  end

  def user_list
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    # params[:user_id] 某用户
    @_type = params[:_type]
    @posts = Post.where(_type: params[:_type], user_id: params[:user_id])
  end
end
