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
    @completed_posts   = current_user.posts.needs.completed.order(updated_at: :desc).page(params[:page]).per(10)
    @done_months       = current_user.posts.needs.where("updated_at >= ?", 3.months.from_now)
  end

  def my_tenders
  end

  def my_followers
  end

  def system_infos
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
      current_user.level = params[:level].to_i
      current_user.save!
      current_user.reload
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
