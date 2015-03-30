# encoding: utf-8
# 用户
class Api::UsersController < Api::BaseController

  skip_before_action :authenticate_user!, only: [ :forget_password ]


  # 取部分用户的基本详情
  #
  # Params:
  #   token:    [String]  valid token
  #   user_ids: [Array]   user ids
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user infos list
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def list
    
    infos = User.where('id in (?)', params[:user_ids] ? params[:user_ids] : []).map(&:to_hash)

    render json: {status: 200, notice: 'success', data: {users: infos}}

    rescue => e
    render json: {status: false, error: e.message}
  end
  
  # 个人中心的基本详情
  #
  # Params:
  #   token:    [String]  valid token
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user infos list
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: [String] 错误的消息
  def show
    remain_info = {
      post_count: @user.posts.needs.count, 
      tender_count: @user.tenders.count,
      following_count: @user.followings.count
    }
    user_info = @user.to_hash.merge(remain_info)
    render json: {status: 200, notice: 'success', data: user_info}
  rescue => ex
    render json: {status: 500, notice: 'failed', error_msg: ex.message}
  end
  
  # 寻车报价是否有更新
  # 
  # Params:
  #  token:    [String]  valid token
  #  updated_at: [DateTime] 更新时间
  # 
  # Returns:
  #  status: [Integer] 200
  #  notice: [String] success
  #  data: 
  # Errors:
  #  status: [Integer] 500
  #  notice: [String] failed
  #  error_msg: [String]       
  def has_updated
    t = params[:updated_at] || Time.now
    
    post_status = @user.posts.needs.where("updated_at > ?", t).count > 0
    tender_status = @user.tenders.where("updated_at > ?", t).count > 0
    
    render json: { status: 200, notice: 'success', data: {post: post_status, tender: tender_status}}
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message}
  end



  # 修改密码
  #
  # Params:
  #   token:        [String] valid token
  #   password      [String] 密码
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String] success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  failed

  def change_password
    @user.password = user_params[:password]
    @user.save!
    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 400, notice: 'failed', error_msg: ex.message }
  end

  # 重置密码
  #
  # Params:
  #   mobile:       [String] 手机号
  #   password      [String] 密码
  #   valid_code    [String] 验证过的验证码
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String] success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  failed

  # LESLIE: 重置密码， 需确保之前操作已进行
  def reset_password
    user = User.find_by_mobile(user_params[:mobile])
    fail("user not found") if user.blank?
    vc = ValidCode.select(:code).where(mobile: user_params[:mobile]).order("created_at desc").first
    fail("valid code is not correct") unless vc.try(:code) == String(params[:valid_code])

    user.password = user_params[:password]
    render json: { status: 200, notice: 'success'}
  rescue => e
    render json: { status: 400, notice: 'failed', error_msg: e.message }
  end

  private

  def user_params
    params.permit(:password, :valid_code, :mobile)
  end
end
