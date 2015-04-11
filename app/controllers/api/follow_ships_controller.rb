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
    render json: {status: true, data: {followers: @user.followers.map(&:to_hash)}}

    rescue => e
    render json: {status: false, error: e.message}
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
    render json: {status: true, data: {followings: @user.followings.map(&:to_hash)}}

    rescue => e
    render json: {status: false, error: e.message}
  end

  # 我关注的人也关注了他
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
    render json: {status: true, data: {joint_followers: @user.followings.map(&:to_hash) & user.followers.map(&:to_hash)}}

    rescue => e
    render json: {status: false, error: e.message}
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

    rescue => e
    render json: {status: false, error: e.message}
  end

  # 关注
  #
  # Params:
  #   token:                      [String]  valid token
  #   following_id:               [Integer] 被关注人的ID
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
    raise '已经关注该用户' if @user.followings.include?(user)

    @user.followings << user

    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 400, notice: ex.message }
  end

  # 取消关注
  #
  # Params:
  #   token:        [String]  valid token
  #   user_id:      [Integer] 被关注人的ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def unfollow
    FollowShip.where(following_id: params[:user_id], follower_id: @user.id).delete_all

    render json: {status: 200, notice: 'success'}
  rescue => ex
    render json: {status: 400, notice: ex.message}
  end

end
