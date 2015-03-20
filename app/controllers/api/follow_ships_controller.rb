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
  #   notice: [String]  请重新再试
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
  #   notice: [String]  请重新再试
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
  #   notice: [String]  请重新再试
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
  #   notice: [String]  请重新再试
  def joint_followings
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {followings: @user.followings & user.followerings}}
  end

  # 关注
  #
  # Params:
  #   token:        [String] valid token
  #   user_id:      [Integer] 第三者用户ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def follow
    user = User.find_by_id(params[:user_id])
    raise 'not found' unless user

    follow_ship = FollowShip.new(follower_id: @user_id, following_id: user.id)
    if follow_ship.save
      render json: {status: 200, notice: 'success'}
    else
      render json: {status: 400, notice: '请重新再试'}
    end
  end

  # 取消关注
  #
  # Params:
  #   token:        [String] valid token
  #   user_id:      [Integer] 第三者用户ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def unfollow
    follow_ship = FollowShip.find_by_follower_id_and_following_id(@user.id, params[:user_id])

    raise 'not found' unless follow_ship

    if follow_ship.delete
      render json: {status: 200, notice: 'success'}
    else
      render json: {status: 400, notice: '请重新再试'}
    end
  end


end
