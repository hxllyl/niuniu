# encoding: utf-8

class UsersController < BaseController
  
  def edit
  end

  def update
    @user = User.find params[:id]
    
    if @user.update_attributes user_params
      if params[:_image].present?
        unless @user.avatar.start_with?('/uploads')
          @user.photos << Photo.new(image: params[:_image], _type: params[:_type])
        else
          avatar = @user.photos.where(_type: 'avatar').first
          avatar.update(image: params[:_image], _type: params[:_type])
        end
      end
      flash[:notice] = @user.errors.full_messages.join('\n')
      render action: :edit
    else
      flash[:notice] = t('success')
      redirect_to my_level_user_path(@user)
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
  end

  def update_my_level
  end

  def about_us
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :role, :company, :area_id, 
                                 { contact: [:company_address, :self_introduction,:finance_header, :photo, :wx]}
                                )  
  end
end
