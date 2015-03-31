class Admin::UsersController < Admin::BaseController

  def search
    if request.xhr?
      @mobile = params[:mobile]
      if @mobile.present?
        @user = User.where(mobile: @mobile).first
      end
    end

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
end
