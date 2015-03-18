# encoding: utf-8
# 关注
class Api::FollowShipsController < Api::BaseController

  # 关注我的人
  #
  # Params:
  #   token:        [String] valid token
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [Hash]    {followers: followers_hash}
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def my_followers
    render json: {status: true, data: {followers: @user.followers}}
  end

  # 我关注的人
  #
  # Params:
  #   token:        [String] valid token
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [Hash]    {followerings: followerings_hash}
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def my_followings
    render json: {status: true, data: {followings: @user.followings}}
  end

  # 共同关注的人
  #
  # Params:
  #   token:        [String]  valid token
  #   user_id:      [Integer] 第三者用户ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [Hash]    {followers: followers_hash}
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def joint_followers
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {followers: @user.followers & user.followers}}
  end

  # 共同的粉丝
  #
  # Params:
  #   token:        [String] valid token
  #   user_id:      [Integer] 第三者用户ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [Hash]    {folloings: followings_hash}
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def joint_followings
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {followings: @user.followings & user.followerings}}
  end


end
