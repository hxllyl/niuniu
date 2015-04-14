class HelpersController < BaseController


  skip_before_action :authenticate_user!

  def show
    @helper = Helper.find params[:id]
    # render layout: false
  end

  def index
    @helpers = Helper.all
    render layout: false
  end

end
