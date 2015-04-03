class Admin::MessagesController < Admin::BaseController

  def index
    @messages = Message.all.includes(:sender, :receiver).
      order('created_at desc').page(params[:page]||1).per(30)
  end

end
