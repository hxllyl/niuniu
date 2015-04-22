# encoding: utf-8
class Admin::PostsController < Admin::BaseController
  before_filter :require_super_admin, except: [:resources_list, :update_sys, :hot_resources]

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

  def resources_list
    @posts = Post.resources.valid.includes(:user, :standard, :brand, :car_model, :base_car).order('updated_at desc').page(params[:page]||1).per(30)
  end

  def update_sys
    post = Post.find_by_id(params[:id])
    post.update_attributes(sys_set_count: Post.valid.resources.map(&:sys_set_count).max.succ)

    redirect_to :back
  end

  # 限八个
  def hot_resources
    @hot_posts = HotPost.all.includes(post: [:user, :standard, :brand, :car_model, :base_car])
  end

end
