# encoding: utf-8
class Admin::UsersController < Admin::BaseController

  def search
    @mobile = params[:mobile]
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
    @mobiles = Log::ContactPhone.where(sender_id: current_staff.id, _type: 0, is_register: false).order('created_at desc').page(params[:page]||1).per(30)
  end

  def registered
    # TODO: Add logic for registered users 已注册用户
    @mobiles = Log::ContactPhone.where(sender_id: current_staff.id, _type: 0, is_register: true).order('updated_at desc').page(params[:page]||1).per(30)
    # @users = User.where(mobile: mobiles).order('created_at desc').page(params[:page]||1).per(30)
  end

  def edit
    @user = User.find_by_id(params[:id])
    if @user.blank?
      redirect_to :back, notice: '很抱歉，此用户不存在'
    end
  end

  # 我来联系, 归入自己的通讯录
  def contact
    @contact_phone = Log::ContactPhone.new(
                mobile: params[:mobile],
                sender_id: current_staff.id
              )
    if @contact_phone.save
      redirect_to contacted_admin_users_path, notice: '已加入通讯录'
    else
      flash[:alert] = @contact_phone.errors.full_messages.join(', ')
      redirect_to search_admin_users_path(mobile: params[:mobile])
    end
  end

end
