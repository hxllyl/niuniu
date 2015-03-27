# encoding: utf-8
class MyPostsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def index
    @_type = params[:_type]
    @posts = current_user.posts.where(_type: params[:type]).order(updated_at: :desc).page(params[:page]).per(10)
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
    @flash     = params[:flash]
  end

  def get_select_infos
    if params[:post][:standard_id]
      @ele = Standard.find_by_id(params[:post][:standard_id])
      @standards = Standard.all
      @brands = @ele.brands.valid
      @car_models = CarModel.where(standard_id: @ele.id, brand_id: @ele.brands.first.id)
      @base_cars = @car_models.first.base_cars
      @outer_colors = @base_cars.first.outer_color
      @inner_colors = @base_cars.first.inner_color
      @areas     = @brands.first.regions
      @price     = nil
    end
    if params[:post][:brand_id]
      @ele = Brand.find_by_id(params[:post][:brand_id])
      @standards = @ele.standards
      @brands = Brand.valid
      @car_models = CarModel.where(standard_id: @standards.first.id, brand_id: @ele.id)
      @base_cars = @car_models.first ? @car_models.first.base_cars : []
      @outer_colors = @base_cars.first.outer_color
      @inner_colors = @base_cars.first.inner_color
      @areas     = @brands.first.regions
      @price     = nil
    end
    if params[:post][:car_model_id]
      @ele = CarModel.find_by_id(params[:post][:car_model_id])
      @standards = Standard.all
      @brands = @ele.standard.brands.valid
      @car_models = CarModel.where(standard_id: @ele.standard_id, brand_id: @ele.brand_id)
      @base_cars = @ele.base_cars
      @outer_colors = @base_cars.first.outer_color
      @inner_colors = @base_cars.first.inner_color
      @areas     = @brands.first.regions
      @price     = @ele.base_cars.count == 1 ? @ele.base_cars.first.base_price : nil
    end
    if params[:post][:base_car_id]
      @ele = BaseCar.find_by_id(params[:post][:base_car_id])
      @standards = Standard.all
      @brands = ele.standard.brands.valid
      @car_models = CarModel.where(standard_id: @ele.standard_id, brand_id: @ele.brand_id)
      @base_cars = @ele.car_model.base_cars
      @outer_colors = @base_cars.first.outer_color
      @inner_colors = @base_cars.first.inner_color
      @areas     = @brands.first.regions
      @price     = ele.base_price
    end


    respond_to do |format|
      format.js
    end
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
