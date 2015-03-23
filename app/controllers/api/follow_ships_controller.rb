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
  #   data:   [JSON]    followers json
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
  #   data:   [JSON]    followerings json
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
  #   data:   [JSON]    joint_followers json
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def joint_followers
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {joint_followers: @user.followers & user.followers}}
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
  #   data:   [JSON]    joint_followings json
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def joint_followings
    user = User.find_by_id(params[:user_id])
    render json: {status: true, data: {joint_followings: @user.followings & user.followerings}}
  end

  # 关注
  #
  # Params:
  #   token:                      [String]  valid token
  #   follow_ship[follower_id]:   [Integer] 关注人的ID
  #   follow_ship[following_id]:  [Integer] 被关注人的ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def create
    user = User.find_by_id(params[:following_id])
    raise 'not found' unless user

    params.require(:follow_ship).permit!

    follow_ship = FollowShip.new(params[:follow_ship])

    if follow_ship.save
      render json: {status: 200, notice: 'success'}
    else
      render json: {status: 400, notice: '请重新再试'}
    end
  end

  # 取消关注
  #
  # Params:
  #   token:        [String]  valid token
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
