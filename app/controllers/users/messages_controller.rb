# encoding: utf-8

class Users::MessagesController < BaseController
  
  def index
    @send_messages = current_user.send_messages
    @received_message = current_user.received_messages
  end
  
  def create
    @message = Message.new message_params
    if @message.save
      flash[:notice] = t('success')
      redirect_to my_level_user_path(current_user)
    else
      flash[:error] = t('failed')
      redirect_to :back
    end
  end
  
  def show
    @message = Message.find params[:id]
  end
  
  private
  def message_params
    params.require(:message).permit(:sender_id, :receiver_id, :title, :content, :_type)
  end
end