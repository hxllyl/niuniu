# encoding: utf-8
class MyPostsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def index
    @_type = params[:_type]
    @brand_id = params[:brand_id]
    @posts = current_user.posts.where(_type: params[:_type]).order(updated_at: :desc).page(params[:page]).per(10)
  end

  def new
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @post = Post.new(_type: params[:_type])
    @standards = Standard.all
    @brands    = Brand.valid
    @car_models = CarModel.where(standard_id: @standards.first.id, brand_id: @standards.first.brands.first.id)
    @base_cars = @car_models.first.base_cars
    @outer_colors = @base_cars.first.outer_color
    @inner_colors = @base_cars.first.inner_color
    @areas     = @brands.first.regions
    @price     = nil
  end

  def get_select_infos
    @standards  = Standard.all
    @standard   = Standard.find_by_id(params[:post][:standard_id])
    @brands     = @standard.brands.valid
    @brand      = params[:post][:brand_id] ? Brand.find_by_id(params[:post][:brand_id]) : nil
    @car_models = @brand ? @brand.car_models.valid : @brands.first.car_models.valid
    @car_model  = params[:post][:car_model_id] ? CarModel.find_by_id(params[:post][:car_model_id]) : nil
    @base_cars  = @car_model ?  @car_model.base_cars.valid : @car_models.first.base_cars.valid

    @car_model = @base_car = @base_cars = @outer_colors = @inner_colors = @areas = @price = 'set_by_itself' if @car_model  == 'set_car_model'
    @base_car = @outer_colors = @inner_colors = @areas = @price = 'set_by_itself' if @base_car  == 'set_base_car'

    render :partial => 'form_select'
  end

  def create
    params.require(:post).permit!
    params[:post][:car_in_areas] = [params[:post][:car_in_areas]]
    @post = Post.new(params[:post])

    @post.user = current_user

    if @post.save
      redirect_to current_user
    else
      render action: new, flash: @post.errors
    end
  end

  def edit
  end

  def update
  end

  def show
    @post  = Post.find_by_id(params[:id])
    @_type = params[:_type]
  end

  def destroy
    post  = Post.find_by_id(params[:id])

    post.update_attributes(status: -1)

    redirect_to user_path
  end
end
