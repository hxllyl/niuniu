# encoding: utf-8
# 用户
class Api::UsersController < Api::BaseController

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
  
  # 认证升级
  # 
  # Params:
  #   token:          [String]   valid token
  #   level:          [integer]  升级到的等级
  #   identity:       [fileData] 身份证件图片
  #   hand_id:        [fileData] 手持身份证
  #   visiting:       [fileData] 名片
  #   room_outer:     [fileData] 展厅门头
  #   room_inner:     [fileData] 展厅内部
  #   license:        [fileData] 营业执照
  # Returns:
  #   status: 200
  #   notice: success
  # Errors:
  #   status: 500
  #   notice: failed
  #   error_msg: 
  
  def update_level
    raise Errors::ArgumentsError.new, 'level参数不存在或比用户level低' if params[:level].blank? or params[:level].to_i <= @user.level 
    
    %w(identity hand_id visiting room_outer room_inner license).each do |t|
      if params[t.to_sym].present?
        photo = @user.send("#{t}")
        if photo
          photo.update(image: params[t.to_sym])
        else
          @user.photos << Photo.new(image: params[t.to_sym], _type: t)
        end
      else
        next
      end
    end
    render json: { status: 200, notice: 'success' }  
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end
  
  private

  def user_params
    params.permit(:password)
  end
end
