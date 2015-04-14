# encoding: utf-8
class UsersController < BaseController

  before_action :can_upgrade?, only: [:update_my_level, :edit_my_level]

  skip_before_action :authenticate_user!, only: [:reset_password]

  def update
    @user = User.find params[:id]
    if @user.update_attributes user_params
      if params[:_image].present?
        avatar = @user.photos.find_by(_type: 'avatar')
        unless avatar
          @user.photos << Photo.new(image: params[:_image], _type: params[:_type])
        else
          avatar.update(image: params[:_image], _type: params[:_type])
        end
      end

      flash[:notice] = t('success')
      redirect_to :back
    else
      flash[:notice] = @user.errors.full_messages.join('\n')
      render action: :edit
    end
  end

  def show
    @uncompleted_posts = current_user.posts.needs.valid.includes(:standard, :brand, :car_model, :base_car).order(updated_at: :desc).page(params[:page]).per(10)
    @completed_posts   = current_user.posts.needs.includes(:standard, :brand, :car_model, :base_car).completed.order(updated_at: :desc)
    # @done_months       = current_user.posts.needs.where("updated_at >= ?", 3.months.from_now)
  end

  def my_tenders
    @uncompleted_tenders = current_user.tenders.includes(post: [:user, :standard, :brand, :car_model, :base_car]).uncompleted.order('updated_at desc').page(params[:page]).per(10)
    @completed_tenders = current_user.tenders.includes(post: [:user, :standard, :brand, :car_model, :base_car]).completed.order('updated_at desc').page(params[:page]).per(10)
  end

  def my_followers
    @key = params[:key]
    if @key
      query = "mobile like ? or name like ?"
      @followings = current_user.followings.where("#{query}", "%#{@key}%", "%#{@key}%").page(params[:page]).per(30)
    else
      @followings = current_user.followings.page(params[:page]).per(30)
    end
  end

  def delete_relation
    clazz = params[:clazz].classify.constantize

    object = clazz.find params[:id]
    if clazz == Post
      if params[:way] == 'resources'
        object.update(status: Post::STATUS.keys[4]) if current_user.send("#{params[:type]}").resources.include?(object)
      else
        object.update(status: Post::STATUS.keys[4]) if current_user.send("#{params[:type]}").needs.include?(object)
        new_counter = current_user.send("#{params[:type]}").needs.count
      end
    elsif clazz == Tender
      object.update(status: Tender::STATUS.keys[2]) if current_user.send("#{params[:type]}").include?(object)
      new_counter = current_user.send("#{params[:type]}").count
    else
      current_user.send("#{params[:type]}").delete object
      new_counter = current_user.send("#{params[:type]}").count
    end

    respond_to do |format|
      format.html {}
      format.json {
        render json: { status: 'success', number: new_counter }
      }
    end
  end

  def add_following
    user = User.find_by_id params[:id]
    raise '关注的对象已不存在' if user.blank?
    raise '已关注' if current_user.following?user

    current_user.followings << user

    render js: "alert('关注成功');$('#following').html('<span>已关注</span>');"

  rescue => ex
    render js: "alert('#{ex.message}');"
  end

  def system_infos
    @sys_messages = current_user.system_messages.order('status asc ,updated_at desc').page(params[:page]).per(5)
    instrument "user.has_read_sys_message", user_id: current_user.id
  end

  def my_level
    @level_status = current_user.can_upgrade
  end

  def edit_my_level
    @level = params[:level].to_i
  end

  def update_my_level
    %w(avatar identity hand_id visiting room_outer room_inner license).each do |t|

      photo = current_user.photos.find_by(_type: t)

      img_box = params[t.to_sym]

      next if img_box.blank? or img_box['_image'].blank?

      if photo
        photo.update(image: img_box[:_image], _type: img_box[:_type])
      else
        current_user.photos << Photo.new(image: img_box[:_image], _type: img_box[:_type])
      end
    end

    instrument 'user.update_level', user_id: current_user.id, start_level: current_user.level, end_level: params[:level] do
      respond_to do |format|
        format.html {
          flash[:notice] = t('success')
          redirect_to :back
        }
      end
    end

  rescue => ex
    respond_to do |format|
      format.html {
        flash[:failed] = t('failed')
        render action: :edit_my_level
      }
    end
  end

  def about_us
    @customer_service = current_user.customer_service
  end

  def reset_password
    @user = User.find(current_user.id) rescue User.find_by(mobile: params[:mobile])
    raise '改号码暂时尚未注册，请先注册！' if @user.blank?

    if @user.update(user_params_without_current_password)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass => true

      if params[:channel] == 'reset_password'
        valid_code = ValidCode.where(mobile: params[:mobile], code: params[:valid_code], \
                                     status: ValidCode::STATUS.keys[0]).first
        raise Errors::ValidCodeNotFoundError.new, t('exceps.not_found_valid_code') if valid_code.blank?
        valid_code.update(status: ValidCode::STATUS.keys[1])
      end

      redirect_to root_path
    else
      render "edit"
    end
  rescue => ex
    flash[:error] = ex.message
    redirect_to '/'
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :role, :company, :area_id,
                                 { contact: [
                                   :company_address,
                                   :self_introduction,
                                   :position_header,
                                   :qq,
                                   :wx]}
                                )
  end

  def can_upgrade?
    unless (current_user.can_upgrade and current_user.can_upgrade_levels.include?(params[:level].to_i))
      flash[:notice] = '不能做该升级操作' and redirect_to(my_level_user_path(current_user))
      return
    end
  end

  def user_params_without_current_password
    params[:user].permit(:password, :password_confirmation)
  end

end
