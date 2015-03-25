# encoding: utf-8
# 用户
class Api::UsersController < Api::BaseController

  # 某对象的评论列表
  #
  # Params:
  #   token:             [String]  valid token
  #   user_ids           [Array]   user ids
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user infos list
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def list

    infos = User.where('id in (?)', params[:user_ids] ? params[:user_ids] : [])

    render json: {status: 200, notice: 'success', data: {users: infos}}

    rescue => e
    render json: {status: false, error: e.message}
  end

end
