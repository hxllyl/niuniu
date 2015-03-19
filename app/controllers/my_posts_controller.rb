# encoding: utf-8

class MyPostsController < ApplicationController
  def index
    @_type = params[:_type]
  end

  def new
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @post = Post.new(_type: params[:_type])
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
    @post  = Post.find(params[:id])
    @_type = params[:_type]
  end
end
