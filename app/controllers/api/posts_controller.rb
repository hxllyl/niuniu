# encoding: utf-8

class Api::PostsController < Api::BaseController

  # 市场资源列表，寻车列表
  def list
    posts = Post.where(_type: params[:_type])

    render json: {status: true, data: {posts: posts.map(&"to_#{params[:type]}_hash".to_sym)}}
  end

  # 我的资源列表，寻车列表
  def my_list
    posts = @user.posts.where(_type: params[:_type])

    render json: {status: true, data: {posts: posts.map(&"to_#{params[:type]}_hash".to_sym)}}
  end

  # 单独的资源，寻车
  def show
    post = Post.find(params[:id])
  end
end
