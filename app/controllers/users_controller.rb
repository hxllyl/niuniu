# encoding: utf-8

class UsersController < BaseController

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
      redirect_to my_level_user_path(@user)
    else
      flash[:notice] = @user.errors.full_messages.join('\n')
      render action: :edit
    end
  end

  def show
    @uncompleted_posts = current_user.posts.needs.where(status: 1).order(updated_at: :desc).page(params[:page]).per(10)
    @completed_posts   = current_user.posts.needs.completed.order(updated_at: :desc)
    @done_months       = current_user.posts.needs.where("updated_at >= ?", 3.months.from_now)
  end

  def my_tenders
    @uncompleted_tenders = Tender.includes(:post).uncompleted.where(user_id: current_user.id).order('updated_at desc').page(params[:page]).per(10)
    @completed_tenders = Tender.includes(:post).completed.where(user_id: current_user.id).order('updated_at desc')
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
     current_user.send("#{params[:type]}").needs.delete object
     new_counter = current_user.send("#{params[:type]}").needs.count
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

  def system_infos
    @sys_messages = current_user.received_messages.where(_type: Message::TYPES.keys[0]).order('updated_at desc').page(params[:page]).per(10)
  end

  def my_level
  end

  def edit_my_level
    @level = params[:level].to_i
  end

  def update_my_level
    %w(avatar identity hand_id visiting room_outer room_inner license).each do |t|
      photo = current_user.photos.find_by(_type: t)
      img_box = params[t.to_sym]
      next if img_box.blank?
      if photo
        photo.update(image: img_box[:_image], _type: img_box[:_type])
      else
        current_user.photos << Photo.new(image: img_box[:_image], _type: img_box[:_type])
      end
    end
    respond_to do |format|
      format.html {
        flash[:notice] = t('success')
        redirect_to my_level_user_path(current_user)
      }
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

  private
  def user_params
    params.require(:user).permit(:name, :role, :company, :area_id,
                                 { contact: [
                                   :company_address,
                                   :self_introduction,
                                   :finance_header,
                                   :photo,
                                   :wx]}
                                )
  end

end
