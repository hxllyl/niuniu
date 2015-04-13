class Admin::HelpersController < Admin::BaseController
  def index
    @helpers = Helper.order(updated_at: :desc).page params[:page]
  end

  def new
    @helper = Helper.new
  end

  def edit
    @helper = Helper.find( params[:id] )
  end

  def update
    helper = Helper.find( params[:id] )
    helper.update_attributes(helper_params)
    # helper.save
    redirect_to admin_helpers_path
  end

  def create
    Helper.create(helper_params)
    redirect_to admin_helpers_path
  end

  def destroy
    Helper.find(params[:id]).delete
    redirect_to admin_helpers_path
  end

  private

  def helper_params
    params.require(:helper).permit(:title, :content)
  end

end