# encoding: utf-8
# 用户
class Api::UsersController < Api::BaseController

  skip_before_filter :verify_authenticity_token, only: [ :reset_password ]
  skip_before_action :auth_user, only: [ :reset_password ]


  # 取部分用户的基本详情
  #
  # Params:
  #   token:      [String]  valid token
  #   user_ids[]: [Array]   user ids
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user infos list
  #
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def list

    infos = User.where('id in (?)', params[:user_ids] ? params[:user_ids] : []).collect{|ele| ele.to_hash.merge(follow_status: @user.following?(ele))}

    render json: {status: 200, notice: 'success', data: {users: infos}}

  rescue => e
    render json: {status: false, error: e.message}
  end

  # 个人详情 当前用户或者其他人
  #
  # Params:
  #   token:    [String]  valid token
  #   id:       [Integer] 用户id（不传就是当前用户信息） 可选
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    user infos list
  #
  # Error
  #   status:     [Integer] 500
  #   notice:     [String]  failed
  #   error_msg:  [String]  错误的消息
  def show
    if params[:id].present?
      user = User.find_by_id params[:id]
    else
      user = @user
    end

    raise '不存在该用户' if user.blank?

    remain_info = {
      post_count: user.posts.needs.count,
      tender_count: user.tenders.count,
      following_count: user.followings.count,
      is_following: @user.following?(user),
      can_upgrade: user.can_upgrade.first,
      valid_level_now: user.can_upgrade.last
    }

    user_info = user.to_hash.merge(remain_info)
    
    render json: {status: 200, notice: 'success', data: user_info}
  rescue => ex
    render json: {status: 500, notice: 'failed', error_msg: ex.message}
  end

  # 寻车报价是否有更新
  #
  # Params:
  #  token:       [String]    valid token
  #  updated_at:  [DateTime]  更新时间
  #
  # Returns:
  #  status: [Integer]  200
  #  notice: [String]   success
  #  data:
  #
  # Errors:
  #  status:    [Integer]       500
  #  notice:    [String]        failed
  #  error_msg: [String]        error json
  def has_updated
    t = params[:updated_at] || Time.now

    post_status   = @user.posts.needs.where("updated_at > ?", t).count > 0
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
  #   level:          [Integer]  升级到的等级
  #   identity:       [FileData] 身份证件图片
  #   hand_id:        [FileData] 手持身份证
  #   visiting:       [FileData] 名片
  #   room_outer:     [FileData] 展厅门头
  #   room_inner:     [FileData] 展厅内部
  #   license:        [FileData] 营业执照
  #
  # Return:
  #   status:             [Integer]   200
  #   notice:             [String]    success
  #   can_update_level:   [Array]     上传成功以后还能继续升级到的等级 e: [2, 3, 4]
  # Error:
  #   status:     [Integer]   500
  #   notice:     [String]    failed
  #   error_msg:  [JSON]      errors json

  def update_level
    raise Errors::ArgumentsError.new, 'level参数不存在或比用户level低' if params[:level].blank? or params[:level].to_i <= @user.level

    %w(identity hand_id visiting room_outer room_inner license).each do |t|
      if params[t.to_sym].present?
        
        photo = @user.photos.find_by(_type: t)
        
        if photo
          photo.update(image: params[t.to_sym], _type: t)
        else
          @user.photos << Photo.new(image: params[t.to_sym], _type: t)
        end
      else
        next
      end
    end

    instrument 'user.update_level',  user_id: @user.id, start_level: @user.level, end_level: params[:level].to_i do
      render json: { status: 200, notice: 'success', can_upgrade: 'false'}
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
  #   notice: [String]  success
  #
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
  #   avatar:                           [fileData] 头像图片
  #   _type:                            [String]   图片类型 这里是 ‘avatar’
  #   user[name]:                       [String]   用户名称
  #   user[role]:                       [String]   用户角色 这里是 ‘normal’
  #   user[company]:                    [String]   用户公司名称
  #   user[area_id]:                    [integer]  用户注册地id
  #   user[contact][company_address]:   [String]   用户公司地址
  #   user[contact][self_introduction]: [String]   用户自我评价
  #   user[contact][position_header]:   [String]   职务抬头
  #   user[contact][phone]:             [String]   联系电话
  #   user[contact][wx]:                [String]   微信
  #   user[contact][qq]:                [String]   qq
  #
  # Return:
  #   status: [Integer]   200
  #   notice: [String]    success
  #
  # Error:
  #   status:     [Integer]   500
  #   notice:     [String]    failed
  #   error_msg:  [Strin]     error json

  def update
   if params[:avatar].present?
     avatar = @user.photos.find_by(_type: 'avatar')
  
     unless avatar
       @user.photos << Photo.new(image: params[:avatar], _type: params[:_type])
     else
       avatar.update(image: params[:avatar], _type: params[:_type])
     end
   end
   
   if params[:user].present?
     if @user.update_attributes update_user_params
      render json: { status: 200, notice: 'success' } and return
     else
      render json: { status: 500, notice: 'failed', error_msg: @user.errors.full_messages.join('\n')} and return
     end
   end
   
   render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end


  # 检查是否有未读
  #
  # Params

  #   _type:                        [String]   0 => 寻车, 1 => 报价, 不传表示 寻车或者报价
  #   token:                       [String]   用户 token

  #
  # Return:
  #   status:         [Integer]   200
  #   notice:         [String]    success
  #   has_unread:     [Boolean]   true or false
  #
  # Error:
  #   status:     [Integer]   500
  #   notice:     [String]    failed
  #   error_msg:  [Strin]     error json
  def check_unread
    # LESLIE: 针对寻车， 需要显示有否对其报价， 针对报价， 显示有否已完成的寻车
    ubool = if params[:_type] == '0'
              @user.has_unread_tenders?
            elsif params[:_type] == '1'
              @user.has_unread_hunts?
            else
              @user.has_unread_hunts? || @user.has_unread_tenders?
            end

    render json: {status: 200, notice: 'success', has_unread: ubool}
  rescue => ex
    render json: {status: 500, notice: 'failed', error_msg: ex.message}
  end

  private

  def user_params
    params.permit(:password, :valid_code, :mobile)
  end

  def update_user_params
    params[:user] = JSON(params[:user]) if params[:user].is_a?String
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
