# encoding: utf-8

class MyPostsController < ApplicationController
  def index
    @_type = params[:_type]
    @posts = current_user.posts.where(_type: params[:type]).order(updated_at: :desc).page(params[:page]).per(10)
  end

  def new
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @post = Post.new(_type: params[:_type])
    @car_infos = Standard.includes(brands: [:car_photo, :base_cars]).map(&:to_hash)
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
    @post  = Post.find_by_id(params[:id])
    @_type = params[:_type]
  end

  def destroy
    post  = Post.find_by_id(params[:id])

    post.update_attributes(status: -1)

    redirect_to user_path
  end
end
