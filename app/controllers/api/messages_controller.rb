# encoding: utf-8
# 消息
class Api::MessagesController < Api::BaseController

  respond_to :json

  # 获得消息
  #
  # Params:
  #   token:     [String]  valid token
  #   updated_at [Date]    更新时间（2015/01/01，默认是一周前）可选
  #   way        [String]  system: 系统消息, customer: 反馈消息
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
    date = params[:updated_at].present? ? params[:updated_at] : 7.days.from_now
    way  = params[:way]
    type, method = way == 'system' ? [Message::TYPES.keys[0], 'recevied_messages'] : [Message::TYPES.keys[1], 'send_messages']
    @msg = @user.send("#{method}").where("_type = ? and updated_at >= ?", type, date).order('updated_at desc')
    render json: { status: 200, notice: 'success', data: @msg.map(&:as_api) }
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
    @message = Message.new message_params
    if @message.save
      render json: { status: 200, notice: 'success' }
    else
      render json: { status: 500, notice: 'failed', error_msg: @message.errors.full_message.join('\n') }
    end
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
    raise 'register_id must be included' if params[:register_id]
    
    device = ActiveDevice.where(user_id: params[:user_id], register_id: params[:register_id]).first_or_initialize
    device.active = params[:method] == 'activating' 
    device.save
    
    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message }
  end
  
  private
  def message_params
    params.require(:message).permit(:sender_id, :receiver_id, :title, :content, :_type)
  end

end
