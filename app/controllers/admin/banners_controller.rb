class Admin::BannersController < Admin::BaseController
  def index
    @banners = Banner.order(updated_at: :desc).page params[:page]
  end

  def new
    @banner = Banner.new
  end

  def edit
    @banner = Banner.find( params[:id] )
  end

  def update
    @banner = Banner.find( params[:id] )
    @banner.attributes = banner_params
    @banner.save
    redirect_to admin_banners_path
  end

  def create
    banner = Banner.new(banner_params)
    if banner.save
      redirect_to admin_banners_path
    else
      render 'new'
    end
  end

  def destroy
    Banner.find(params[:id]).delete
    redirect_to admin_banners_path
  end

  private

  def banner_params
    params.require(:banner).permit( :title, :image, :begin_at, :end_at, :poi, :position, :use, :redirect_way )
  end
end
