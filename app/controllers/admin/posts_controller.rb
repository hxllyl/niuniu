class Admin::PostsController < Admin::BaseController

  def index
    unvalid_bc_ids = BaseCar.unvalid.map(&:id)
    @posts = Post.where(base_car_id: unvalid_bc_ids).includes(:user).order('created_at desc').page(params[:page]||1).per(30)
  end

end
