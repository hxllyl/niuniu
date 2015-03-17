# encoding: utf-8

class Api::PostsController < Api::BaseController

  # 市场资源列表，寻车列表
  def list
    posts = Post.where(_type: params[:_type])

    render json: {status: true, data: {posts: posts.map(&:to_hash)}}
  end

  # 我的资源列表，寻车列表
  def my_list
    posts = @user.posts.where(_type: params[:_type])

    render json: {status: true, data: {posts: posts.map(&:to_hash)}}
  end
end
