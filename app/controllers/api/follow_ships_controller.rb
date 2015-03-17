# encoding: utf-8

class Api::FollowShipsController < Api::BaseController

  # 关注我的人
  def my_followers
    render json: {status: true, data: {followers: @user.followers}
  end

  # 我关注的人
  def my_followings
    render json: {status: true, data: {followings: @user.followings}
  end

  # 共同关注的人
  def joint_followers
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {followers: @user.followers & user.followers}
  end

  # 共同的粉丝
  def joint_followings
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {followings: @user.followings & user.followerings}
  end


end
