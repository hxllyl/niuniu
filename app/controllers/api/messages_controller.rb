# encoding: utf-8
# 消息
class Api::MessagesController < Api::BaseController

  respond_to :json

  # 获得消息
  #
  # Params:
  #   token:     [String]  valid token
  #   page:      [integer] 当前页（分页）
  #   way:       [String]  system: 系统消息, customer: 反馈消息
  #
  # Returns:
  #   status: 状态码（200）
  #   notice: success
  #   data: 数据
  #
  # Errors:
  #   status: 状态码（500）
  #   notice: failed
  #   error_msg: 错误消息

  def index
    page_size = params[:page_size] || 10
    page = (params[:page].nil? or params[:page].to_i == 0) ? 1 : params[:page].to_i
    way  = params[:way]
    if way == 'system'
      messages = @user.system_messages.order('updated_at desc').offset(page*page_size).limit(page_size)
    end
    
    render json: { status: 200, notice: 'success', data: messages.map(&:for_api)}
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end

  # 反馈意见
  #
  # params:
  #   message[sender_id]    [Integer] 发送人id
  #   message[receiver_id]  [Integer] 收信人id
  #   message[_type]        [Integer] 1 表示反馈意见
  #   message[content]      [String] 反馈意见内容
  # Returns:
  #   status: 状态码（200）
  #   notice: success
  # Errors:
  #   status: 500
  #   notice: failed
  #   error_msg: 错误信息

  def create
    @fb = Feedback.new message_params
    if @fb.save
      render json: { status: 200, notice: 'success' }
    else
      render json: { status: 500, notice: 'failed', error_msg: @fb.errors.full_message.join('\n') }
    end
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end
  
  # 更新消息状态
  #
  # Params:
  #   token:    [String] 用户的token
  #   ids:      [Array] 消息的id 多个
  # Returns:
  #   status:   200
  #   notice:   success
  # Errors
  #   status:   500
  #   notice:   failed
  #   error_msg  错误消息
  
  def update_messages
    raise '参数ids不存在或为空' if params[:ids].nil? or params[:ids].empty?
    
    messages = @user.received_messages.where('messages.id in (?)', params[:ids]).update_all(status: Message::STATUS.keys[1])
    
    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end
  
  # 删除系统消息
  #
  # Params:
  #   token:    [String] 用户的token
  #   ids:      [Array] 消息的id 多个
  # Returns:
  #   status:   200
  #   notice:   success
  # Errors
  #   status:   500
  #   notice:   failed
  #   error_msg  错误消息
  
  def destroy_messages
    raise '参数ids不存在或为空' if params[:ids].nil? or params[:ids].empty?
    
    @user.received_messages.where("messages.ids in (?)", params[:ids]).clear
    
    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }  
  end
  
  # 注册或激活灭活设备(jpush)
  #
  # Params:
  #   token:        [String] 用户token
  #   register_id:  [String] jpush register_id
  #   method:       [String] activating 激活(如果该register_id是第一次激活, 会先插入数据再激活)，inactivated 灭活
  # Returns:
  #   status: 200
  #   notice: success
  # Errors:
  #   status: 500
  #   notice: failed
  #   error_msg: 错误信息
   
  def device_methods
    raise 'register_id must be included' if params[:register_id].blank?
    
    device = ActiveDevice.where(user_id: @user.id, register_id: params[:register_id]).first_or_initialize
    device.active = params[:method] == 'activating' 
    device.save!
    
    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end
  
  private
  def message_params
    params.require(:feedback).permit(:sender_id, :receiver_id, :title, :content, :_type)
  end

end
