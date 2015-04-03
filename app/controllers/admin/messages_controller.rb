class Admin::MessagesController < Admin::BaseController

  def index
    @messages = Message.all.includes(:sender, :receiver).
      order('created_at desc').page(params[:page]||1).per(30)
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params.merge({sender_id: current_staff.id}))

    if @message.save
      redirect_to admin_messages_path, notice: '已发送'
    else
      render :new, alert: @message.errors.full_messages.join(', ')
    end
  end

  private
  def message_params
    params.require(:message).permit(:receiver_group, :title, :content)
  end
end
