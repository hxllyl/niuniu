# encoding: utf-8
class Admin::UsersController < Admin::BaseController
  before_filter :require_super_admin, only: [:staff_list]

  def search
    @mobile_log = Log::ContactPhone.find_or_initialize_by(mobile: params[:mobile])

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def contacted
    # TODO: Add logic for contacted users 已联系用户
    conds = {_type: 0, is_register: false}
    conds[:sender_id] = current_staff.id if staff?
    conds[:mobile] = params[:mobile] if params[:mobile].present?
    @mobiles = Log::ContactPhone.where(conds).order('updated_at desc').page(params[:page]||1).per(30)
    @show_datas = staff? ?  [
                              current_staff.log_contact_phones.today.count,
                              current_staff.log_contact_phones.month.count,
                              current_staff.log_contact_phones.count
                            ] : [
                              Log::ContactPhone.today.count,
                              Log::ContactPhone.month.count,
                              Log::ContactPhone.count
                            ]
  end

  def registered
    # TODO: Add logic for registered users 已注册用户
    
    @sort_way = params[:sort_way].present? ? "#{params[:sort_way]} asc" : 'created_at desc' 
    
    @users =  if staff?
                current_staff.customers.order("#{@sort_way}").page(params[:page]||1).per(30)
              else
                 User.where("customer_service_id is not NULL").order("#{@sort_way} desc").page(params[:page]||1).per(30)
              end
    
    @users = @users.where(mobile: params[:mobile]) if params[:mobile].present?
              
    @show_datas = staff? ?  [
                              current_staff.customers.today.count,
                              current_staff.customers.month.count,
                              current_staff.customers.count
                            ] : [
                              User.where("customer_service_id is not NULL").today.count,
                              User.where("customer_service_id is not NULL").month.count,
                              User.where("customer_service_id is not NULL").count
                            ]
  end

  def new
    user_hash = if params[:mask] == 'Staff'
                  {
                    mask: 'Staff',
                    contact: {
                      wx:              nil,
                      qq:              nil,
                      remark:          nil,
                      company_address: nil,
                      phone:           nil,
                      web_site:        nil,
                      company_email:   nil
                    }
                  }
                else
                  params.require(:user).permit!
                  params[:user].merge(
                    contact:  {
                                company_address:    nil,
                                position_header:    nil,
                                wx:                 nil,
                                qq:                 nil,
                                self_introduction:  nil
                  })
                end
    @user = User.new(user_hash)
  end

  def create
    if params[:staff]
      params.require(:staff).permit!
      @user = Staff.new(params[:staff])
      @user.role = 'staff'
    else
      params.require(:user).permit!
      @user = User.new(params[:user])
    end
    
    if params[:_image].present?
      avatar = @user.photos.where(_type: 'avatar').first_or_initialize 
      avatar.image = params[:_image]
      avatar._type = 'avatar'
      avatar.save
    end

    if @user.save
      if @user.mask.nil?
        log = Log::ContactPhone.where(mobile: @user.mobile).first_or_initialize
        log.is_register = true
        log._type = 0
        log.reg_admin = @current_staff
        log.save
        @user.contact[:remark] = log.remark
        @user.save
        redirect_to registered_admin_users_path
      else
        redirect_to staff_list_admin_users_path
      end
    else
      logger.info "errors message:" + @user.errors.full_messages.join('\n')
      render :new
    end
  end

  def edit
    @user = User.find_by_id(params[:id])
    if @user.blank?
      redirect_to :back, notice: '很抱歉，此用户不存在'
    end
  end

  def update
    @user = User.find_by_id(params[:id])
    
    if params[:_image].present?
      avatar = @user.photos.where(_type: 'avatar').first_or_initialize 
      avatar.image = params[:_image]
      avatar._type = 'avatar'
      avatar.save
    end
    
    if @user.mask.blank? or @user.mask != 'Staff'
      params.require(:user).permit!
      @user.update_attributes(params[:user])
      
      redirect_to registered_admin_users_path
    else
      params.require(:staff).permit!
      @user.update_attributes(params[:staff])

      redirect_to staff_list_admin_users_path
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

  # 指定业务员
  def set_staff
    @contact_phone = Log::ContactPhone.new(
                mobile: params[:mobile],
                sender_id: params[:staff_id]
              )
    if @contact_phone.save
      redirect_to contacted_admin_users_path, notice: '已加入通讯录'
    else
      flash[:alert] = @contact_phone.errors.full_messages.join(', ')
      redirect_to search_admin_users_path(mobile: params[:mobile])
    end
  end

  def index
    @mobile = params[:mobile] && params[:mobile] != "" ? params[:mobile] : nil
    @level  = params[:level] && params[:level]!= "" ? params[:level] : nil

    conds = {role: 'normal'}
    conds[:mobile] = @mobile if @mobile
    conds[:level]  = @level  if @level

    @users = User.where(conds).includes(:customer_service).order(created_at: :desc).page(params[:page]||1).per(30)
  end

  def staff_list
    @staffs = Staff.order(created_at: :desc).page(params[:page]||1).per(30)
  end

  def edit_staff
    @user = User.find_by_id(params[:id])
  end

  def update_staff
    @user = User.find_by_id(params[:id])

    params.require(:user).permit!

    @user.update_attributes(params[:user])

    redirect_to staff_list_admin_users_path
  end

  def update_remark
    mobile = Log::ContactPhone.find_by_id(params[:id])
    mobile.remark = params[:remark]
    mobile.save

    redirect_to :back
  end

  def update_status
    user = User.find_by_id(params[:id])
    user.update_attributes(status: params[:status].to_i)

    redirect_to :back
  end

  def update_role
    staff = Staff.find_by_id(params[:id])
    staff.update_attributes(role: params[:role])

    redirect_to :back
  end
  
  def update_user_remark
    user = User.find params[:id]
    user.contact[:remark] = params[:remark]
    user.save
     
    redirect_to :back
  end

end
