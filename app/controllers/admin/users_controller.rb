class Admin::UsersController < Admin::BaseController

  def search
    if request.xhr?
      @user = User.find_by_mobile(params[:mobile])
      # @mobile = Log::ContactPhone.find_by_mobile(params[:mobile])
    end

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def contacted
    # TODO: Add logic for contacted users 已联系用户
    @users = User.order('created_at desc').page(params[:page]||1).per(30)
  end

  def registered
    # TODO: Add logic for registered users 已注册用户
    @users = User.order('created_at desc').page(params[:page]||1).per(30)
  end

  def edit
    @user = User.find_by_id(params[:id])
    if @user.blank?
      redirect_to :back, notice: '很抱歉，此用户不存在'
    end
  end

  # 我来联系, 归入自己的通讯录
  def contact
    @mobile = Log::ContactPhone.new(
                mobile: params[:mobile],
                sender_id: current_user.id
              )
    if @mobile.save
    else
    end
  end

end
