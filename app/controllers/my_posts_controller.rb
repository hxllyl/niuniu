# encoding: utf-8
class MyPostsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def index
    @_type = params[:_type]
    @brand_id = params[:brand_id]
    unless @brand_id.blank?
      @posts = current_user.posts.joins(:brand).where("brands.id = #{@brand_id} and posts._type = #{@_type}").order(position: :asc , updated_at: :desc).page(params[:page]).per(10)
    else
      @posts = current_user.posts.where(_type: @_type).order(position: :asc, updated_at: :desc).page(params[:page]).per(10)
    end

    if params[:update_all]
      current_user.posts.where("posts._type = #{@_type} and posts.id in (?)", params[:resource_ids].split(' ')).update_all(updated_at: Time.now())
    end

    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def new
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @post = Post.new(_type: params[:_type])
    @standards = Standard.all
    @brands    = @standards.first.brands.valid
    @brand     = @brands.first
    @car_models = CarModel.where(standard_id: @standards.first.id, brand_id: @standards.first.brands.first.id, status: 1)
    @base_cars = @car_models.first.base_cars
    @base_car  = @base_cars.first
    @post_type = @post._type
  end

  def get_select_infos
    @post       = Post.new
    @standards  = Standard.all
    @standard   = Standard.find_by_id(params[:post][:standard_id])
    @brands     = @standard.brands.valid
    @brand      = params[:post][:brand_id] ? Brand.find_by_id(params[:post][:brand_id]) : @brands.first
    @car_models = CarModel.where(standard_id: @standard.id, brand_id: @brand.id, status: 1)
    @post_type  = params[:post][:_type].to_i
    if params[:post][:car_model_id]  == 'set_car_model'
      @car_model = 'set_car_model'
      @base_car  = 'set_base_car'
    else
      @car_model  = params[:post][:car_model_id] ? CarModel.find_by_id(params[:post][:car_model_id]) : @car_models.first
      @base_cars  = @car_model.base_cars.valid
      @base_car   = params[:post][:base_car_id] ? BaseCar.find_by_id(params[:post][:base_car_id]) : @base_cars.first
    end

    if params[:post][:base_car_id]  == 'set_base_car'
      @base_car  = 'set_base_car'
      @car_model  = params[:post][:car_model_id] ? CarModel.find_by_id(params[:post][:car_model_id]) : @car_models.first
      @base_cars  = @car_model.base_cars.valid
    end

    render :partial => 'form_select'
  end

  def create
    standard  = Standard.find_by_id(params[:post][:standard_id])
    brand     = Brand.find_by_id(params[:post][:brand_id])
    car_model = CarModel.find_by_id(params[:post][:car_model_id])
    base_car  = BaseCar.find_by_id(params[:post][:base_car_id])

    car_model = CarModel.create(
                  standard_id: standard.id,
                  brand_id: brand.id,
                  name: params[:post][:car_model_id],
                  status: 0
                ) unless car_model

    base_car  = BaseCar.create(
                  standard_id: standard.id,
                  brand_id: brand.id,
                  car_model_id: car_model.id,
                  style: params[:post][:base_car_id],
                  outer_color: [params[:post][:outer_color]],
                  inner_color: [params[:post][:inner_color]],
                  status: 0
                ) unless base_car

    # 为资源库保存自定义的颜色
    Log::BaseCar.create(
      user_id: current_user.id,
      base_car_id: base_car.id,
      method_name: 'outer_color',
      content: params[:post][:outer_color]
    ) unless base_car.outer_color.include?(params[:post][:outer_color])

    Log::BaseCar.create(
      user_id: current_user.id,
      base_car_id: base_car.id,
      method_name: 'inner_color',
      content: params[:post][:inner_color]
    ) unless base_car.inner_color.include?(params[:post][:inner_color])

    params.require(:post).permit!
    params[:post][:car_in_areas] = [params[:post][:car_in_areas]] if params[:post][:car_in_areas]
    params[:post][:car_model_id] = car_model.id
    params[:post][:base_car_id]  = base_car.id

    photos = params[:post].delete(:post_photos)
    @post  = Post.new(params[:post])
    photos && photos.each do |k, v|
      @post.post_photos.new(_type: k, image: v.first.values.first.tempfile)
    end

    @post.user = current_user

    if @post.save
      redirect_to @post._type == 0 ? user_my_posts_path(current_user, _type: 0) : current_user
    else
      render action: new, flash: @post.errors
    end
  end

  def edit
    @post  = Post.find_by_id(params[:id])
    @standards = Standard.all
    @standard  = @post.standard
    @brands    = @standards.first.brands.valid
    @brand     = @post.brand
    @car_models = CarModel.where(standard_id: @standards.first.id, brand_id: @standards.first.brands.first.id, status: 1)
    @car_model = @post.car_model
    @base_cars = @car_models.first.base_cars
    @base_car  = @post.base_car
    @post_type = @post._type
  end

  def update
    @post = Post.find_by_id(params[:id])
    standard  = Standard.find_by_id(params[:post][:standard_id])
    brand     = Brand.find_by_id(params[:post][:brand_id])
    car_model = CarModel.find_by_id(params[:post][:car_model_id])
    base_car  = BaseCar.find_by_id(params[:post][:base_car_id])

    # 为资源库保存自定义的颜色
    Log::BaseCar.create(
      user_id: current_user.id,
      base_car_id: base_car.id,
      method_name: 'outer_color',
      content: params[:post][:outer_color]
    ) unless base_car.outer_color.include?(params[:post][:outer_color])

    Log::BaseCar.create(
      user_id: current_user.id,
      base_car_id: base_car.id,
      method_name: 'inner_color',
      content: params[:post][:inner_color]
    ) unless base_car.inner_color.include?(params[:post][:inner_color])

    params[:post][:car_in_areas] = [params[:post][:car_in_areas]] if params[:post][:car_in_areas]

    photos = params[:post].delete(:post_photos)
    params.require(:post).permit!
    @post.attributes = params[:post]
    photos && photos.each do |k, v|
      photo = @post.post_photos.find_by__type(k)
      if photo
        photo.update_attributes(image: v.first.values.first.tempfile)
      else
        @post.post_photos.new(_type: k, image: v.first.values.first.tempfile)
      end
    end

    if @post.save
      redirect_to user_my_posts_path(current_user, _type: 0)
    else
      render action: edit, flash: @post.errors
    end
  end

  def show
    # 暂无用
  end

  def destroy
    post  = Post.find_by_id(params[:id])

    post.update_attributes(status: -1)

    redirect_to user_path
  end

  # 更新post位置
  def update_position
    post = current_user.posts.find params[:id]
    params[:type] == 'up' ? post.move_higher : post.move_lower
    respond_to do |format|
      format.js {
        render nothing: true
      }
    end
    # render nothing
  end
end
