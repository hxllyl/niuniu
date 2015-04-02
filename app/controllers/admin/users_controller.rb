class Admin::UsersController < Admin::BaseController

  def search
    if request.xhr?
      @mobile = params[:mobile]
      if @mobile.present?
        @user = User.where(mobile: @mobile).first.to_hash
      end
    end

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def contacted
    # TODO: Add logic for contacted users 已联系用户
    @users = User.page(params[:page]||1).order('created_at desc').per(30)
  end

  def registered
    # TODO: Add logic for registered users 已注册用户
    @users = User.page(params[:page]||1).order('created_at desc').per(30)
  end

  def edit
    @user = User.find_by_id(params[:id])
    if @user.blank?
      redirect_to :back, notice: '很抱歉，此用户不存在'
    end
  end

end
