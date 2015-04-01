# encoding: utf-8
# 用户
class Api::UsersController < Api::BaseController

  skip_before_filter :verify_authenticity_token, only: [ :reset_password ]
  skip_before_action :auth_user, only: [ :reset_password ]


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

    infos = User.where('id in (?)', params[:user_ids] ? params[:user_ids] : []).collect{|ele| ele.to_hash.merge(follow_status: @user.following?(ele))}

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
  #   password:     [String] 密码
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

    instrument 'user.update_level',  user_id: @user.id, start_level: @user.level, end_level: params[:level] do
      render json: { status: 200, notice: 'success' }
    end

  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end

  # 重置密码
  #
  # Params:
  #   mobile:        [String] 手机号
  #   password:      [String] 密码
  #   valid_code:    [String] 验证过的验证码
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
    vc = ValidCode.where(mobile: user_params[:mobile]).order("created_at desc").first
    fail("valid code is not correct") unless vc.try(:code) == String(params[:valid_code])

    user.password = user_params[:password]
    user.save!
    render json: { status: 200, notice: 'success'}
  rescue => e
    render json: { status: 400, notice: 'failed', error_msg: e.message }
  end

  # 更新个人资料
  #
  # Params
  #   avatar:         [fileData] 头像图片
  #   _type:          [String]   图片类型 这里是 ‘avatar’
  #   user['name']:   [String]   用户名称
  #   user['role']:   [String]   用户角色 这里是 ‘normal’
  #   user['company'] [String]   用户公司名称
  #   user['area_id'] [integer]  用户注册地id
  #   user['contact']['company_address']   [String]     用户公司地址
  #   user['contact']['self_introduction'] [String]     用户自我评价
  #   user['contact']['position_header']   [String]     职务抬头
  #   user['contact']['photo']             [String]     联系电话
  #   user['contact']['wx']                [String]     微信
  # Returns:
  #   status: 200
  #   notice: success
  # Errors:
  #   status: 500
  #   notice: failed
  #   error_msg:

  def update
    if @user.update_attributes update_user_params
     if params[:avatar].present?
        avatar = @user.photos.find_by(_type: 'avatar')
        unless avatar
          @user.photos << Photo.new(image: params[:avatar], _type: params[:_type])
        else
          avatar.update(image: params[:avatar], _type: params[:_type])
        end
      end
      render json: { status: 200, notice: 'success' }
     else
      render json: { status: 500, notice: 'failed', error_msg: @user.errors.full_messages.join('\n')}
     end
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end

  private

  def user_params
    params.permit(:password, :valid_code, :mobile)
  end

  def update_user_params
    params.require(:user).permit(:name, :role, :company, :area_id,
                                  { contact: [
                                   :company_address,
                                   :self_introduction,
                                   :position_header,
                                   :qq,
                                   :wx]}
                                )
  end

end
