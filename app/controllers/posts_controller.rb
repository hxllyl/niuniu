# encoding: utf-8

class PostsController < ApplicationController

  def index
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @_type = params[:_type]
    @posts = Post.where(_type: params[:_type])
  end

  def show
  end
end
