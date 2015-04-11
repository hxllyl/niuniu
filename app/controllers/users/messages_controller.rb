# encoding: utf-8

class Users::MessagesController < BaseController
  
  def index
    @send_messages = current_user.send_feedbacks
    @received_message = current_user.received_feedbacks
  end
  
  def create
    @fb = Feedback.new message_params
    if @fb.save
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
    params.require(:feedback).permit(:sender_id, :receiver_id, :title, :content, :_type)
  end
end