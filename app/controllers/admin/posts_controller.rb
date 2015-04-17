# encoding: utf-8
class Admin::PostsController < Admin::BaseController
  before_filter :require_super_admin

  def index
    unvalid_bc_ids = BaseCar.unvalid.map(&:id)
    @posts = Post.valid.where(base_car_id: unvalid_bc_ids).includes(:user, :standard, :brand, :car_model, :base_car).order('created_at desc').page(params[:page]||1).per(30)
  end

  def destroy
    @post = Post.find_by_id(params[:id])

    @post.update_attributes(status: -1)

    redirect_to :back
  end

  def approve_base_car
    ele = params[:resource_type].classify.constantize.find_by_id(params[:resource_id])

    ele.update_attributes(status: 1)

    redirect_to :back
  end

end
