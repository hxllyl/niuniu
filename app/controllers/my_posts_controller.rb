# encoding: utf-8
class MyPostsController < BaseController
  before_filter :auth_my_self
  skip_before_filter :verify_authenticity_token


  def index
    @_type = params[:_type]
    @brand_id = params[:brand_id]
    unless @brand_id.blank?
      @posts = current_user.posts.valid.includes(:standard, :base_car, :car_model).joins(:brand).where("brands.id = #{@brand_id} and posts._type = #{@_type}").page(params[:page]).per(10)
    else
      @posts = current_user.posts.valid.includes(:standard, :base_car, :car_model).where(_type: @_type).page(params[:page]).per(10)
    end

    if params[:update_all]
      if current_user.could_update_my_resources?
        current_user.posts.resources.valid.update_all(updated_at: Time.now())
        current_user.gen_post_log(current_user.posts.resources.valid.first, 'update_all')
      else
        flash[:notice] = '对不起，您一个小时之内不能重复更新您的资源列表'
      end
    end

    @brands = current_user.posts.resources.includes(:brand).map(&:brand).uniq

    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def new
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    @post = Post.new(_type: params[:_type])

    @standards  = Standard.all
    @standard   = Standard.first
    @brands     = @standard.brands.valid
    @brand      = @brands.first
    @car_models = CarModel.where(standard_id: @standards.first.id, brand_id: @brand.id, status: 1)
    @car_model  = @car_models.first
    @base_cars  = @car_model.base_cars.valid
    @base_car   = @base_cars.first
    @post_type  = @post._type
    @standard, @brand, @car_model, @base_car = *nil
  end

  def get_select_infos
    @post       = Post.new
    @post_type  = params[:post][:_type].to_i
    @standard   = Standard.find_by_id(params[:post][:standard_id])
    @brand      = Brand.find_by_id(params[:post][:brand_id])
    @car_model  = CarModel.find_by_id(params[:post][:car_model_id])
    @base_car   = BaseCar.find_by_id(params[:post][:base_car_id])

    @standards  = Standard.all
    @brands     = @standard.brands.valid
    @car_models = @brand ? CarModel.where(standard_id: @standard.id, brand_id: @brand.id, status: 1) : nil
    @base_cars  = @car_model ? @car_model.base_cars.valid : nil

    @car_model, @base_car = 'set_car_model', 'set_base_car' if  params[:post][:car_model_id]  == 'set_car_model'
    @base_car   = 'set_base_car' if params[:post][:base_car_id]  == 'set_base_car'

    render :partial => 'form_select'
  end

  def create
    standard  = Standard.find_by_id(params[:post][:standard_id])
    brand     = Brand.find_by_id(params[:post][:brand_id])
    car_model = CarModel.where(id: params[:post][:car_model_id], standard_id: standard.id, brand_id: brand.id).first
    base_car  = car_model ? BaseCar.where(standard_id: standard.id, brand_id: brand.id, id: params[:post][:base_car_id]).first : nil

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
      user_id:      current_user.id,
      base_car_id:  base_car.id,
      method_name:  'outer_color',
      content:      params[:post][:outer_color]
    ) unless base_car.outer_color.include?(params[:post][:outer_color])

    Log::BaseCar.create(
      user_id:      current_user.id,
      base_car_id:  base_car.id,
      method_name:  'inner_color',
      content:      params[:post][:inner_color]
    ) unless base_car.inner_color.include?(params[:post][:inner_color])

    params.require(:post).permit!
    params[:post][:car_model_id] = car_model.id
    params[:post][:base_car_id]  = base_car.id

    photos = params[:post].delete(:post_photos)
    @post  = Post.new(params[:post])
    photos && photos.each do |k, v|
      @post.post_photos.new(_type: k, image: v.first.values.first.tempfile)
    end

    @post.user = current_user

    if @post.save
      redirect_to @post._type == 0 ? user_my_posts_path(current_user, _type: 0) : user_path(current_user)
    else
      render action: new, flash: @post.errors
    end
  end

  def edit
    @post       = Post.find_by_id(params[:id])
    @standards  = Standard.all
    @standard   = @post.standard
    @brands     = @standard.brands
    @brand      = @post.brand
    @car_models = CarModel.where(standard_id: @standard.id, brand_id: @brand.id)
    @car_model  = @post.car_model
    @base_cars  = @car_model.base_cars
    @base_car   = @post.base_car
    @post_type  = @post._type

    @discount_contents =  if @post.expect_price.to_f > @post.guiding_price.to_f
                            [nil, nil, (@post.expect_price.to_f - @post.guiding_price.to_f).round(2)]
                          else
                            [((@post.guiding_price.to_f - @post.expect_price.to_f)/@post.guiding_price.to_f*100).round(2), (@post.guiding_price.to_f - @post.expect_price.to_f).round(2), nil]
                          end
    @discount_contents << @post.expect_price
  end

  def update
    @post = Post.find_by_id(params[:id])
    standard  = Standard.find_by_id(params[:post][:standard_id])
    brand     = Brand.find_by_id(params[:post][:brand_id])
    car_model = CarModel.find_by_id(params[:post][:car_model_id])
    base_car  = BaseCar.find_by_id(params[:post][:base_car_id])

    # 为资源库保存自定义的颜色
    Log::BaseCar.create(
      user_id:      current_user.id,
      base_car_id:  base_car.id,
      method_name:  'outer_color',
      content:      params[:post][:outer_color]
    ) unless base_car.outer_color.include?(params[:post][:outer_color])

    Log::BaseCar.create(
      user_id:      current_user.id,
      base_car_id:  base_car.id,
      method_name:  'inner_color',
      content:      params[:post][:inner_color]
    ) unless base_car.inner_color.include?(params[:post][:inner_color])

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
    @post = Post.find_by_id(params[:id])

    # LESLIE: 浏览该页面 意味着已查看了所有对该寻车的报价
    payload = { post_id: @post.id, method_name: 'tender' }
    instrument 'user.has_read_tender', payload
  end

  def destroy
    post  = Post.find_by_id(params[:id])

    post.update_attributes(status: -1)

    redirect_to user_path
  end

  # 更新post位置
  def update_position
    post = current_user.posts.resources.find params[:id]

    type = params[:type]
    swap_obj = current_user.posts.resources.find params[:swap_id]

    unless (type == 'down' and post.first?) or ( type == 'up' and post.last?)
      swap_tmp(post, swap_obj)
      post.save
      swap_obj.save
    end

    respond_to do |format|
      format.json {
        render nothing: true
      }
    end
    # render nothing
  end

  private

  def swap_tmp(objx, objy, temp=nil)
    temp = objx.position
    objx.position = objy.position
    objy.position = temp
  end

end
