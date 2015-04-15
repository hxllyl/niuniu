# encoding: utf-8
require_relative '../../app/services/query_posts'
class PostsController < BaseController
   skip_before_filter :verify_authenticity_token, only: [:tender, :complete, :create]
   before_filter :auth_staff, only: [:new, :create, :edit, :update]

  def index
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    # 资源每人最新一条，寻车，所有
    @_type      = params[:_type]
    @standards  = Standard.all
    @brands     = Brand.where(name: APP_CONFIG['brands'].split(' '))
    @car_models = CarModel.where(name: APP_CONFIG['car_models'].split(' ')).select("DISTINCT on (name) *")
    if @_type.to_i == 1
      @posts   = Post.needs.valid.includes(:user, :car_model, :standard, :base_car, brand: [:car_photo]).order(created_at: :desc).page(params[:page]).per(10)
    else
      posts   = Post.resources.valid.includes(:user, :car_model, :standard, :base_car, :brand).order(updated_at: :desc).group_by(&:user_id).collect{|k, v| v.first}
      @posts  =  Kaminari.paginate_array(posts).page(params[:page]).per(10)
    end
  end

  # 市场资源点击品牌进入资源列表页
  # params: st=1&br=1&cm=1&bc=1&oc=xx&ic=xx&rt=xx
  def resources_list
    @standard   = Standard.includes(:brands).find_by_id(params[:st])
    @brand      = Brand.includes(:standards).find_by_id(params[:br])
    @car_model  = CarModel.includes(:base_cars, :standard, :brand).find_by_id(params[:cm])
    @base_car   = BaseCar.includes(:car_model, :brand, :standard).find_by_id(params[:bc])

    @standard, @brand = @car_model.standard, @car_model.brand if @car_model

    @standards  = @brand      ? @brand.standards : Standard.all
    @brands     = @standard   ? @standard.brands.valid : Brand.valid
    @car_models = @brand && @standard ? CarModel.where(standard_id: @standard.id, brand_id: @brand.id).valid : []
    @base_cars  = @car_model  ? @car_model.base_cars.valid.order(base_price: :asc) : []

    @q_json       = {}
    @q_json[:st]  = @standard.id   if @standard
    @q_json[:br]  = @brand.id      if @brand
    @q_json[:cm]  = @car_model.id  if @car_model

    if @base_car
      @q_json[:bc]          = @base_car.id
      conds                 = {status: 1}
      conds[:outer_color]   = params[:oc] && @q_json[:oc] = params[:oc]  if params[:oc]
      conds[:inner_color]   = params[:ic] && @q_json[:ic] = params[:ic]  if params[:ic]
      conds[:resource_type] = params[:rt] && @q_json[:rt] = params[:rt]  if params[:rt]

      @order_ele  = params[:order_by] ? Post::ORDERS[params[:order_by].to_sym] : nil
      @order_by   = params[:order_by] == 'expect_price' ? {expect_price: :asc} : {updated_at: :desc}

      @posts      = @base_car.posts.resources.valid.where(conds).order(@order_by).page(params[:page]).per(10)
    end
  end

  # 一键找车列表页
  def key_search
    order_by = {   'updated_at' =>  'updated_at', 'expect_price' => 'expect_price'  }.fetch(params[:order_by]) { 'updated_at' }
    @q_json    = {q: params[:q]}
    @order_ele = params[:order_by] ? Post::ORDERS[params[:order_by].to_sym] : nil
    u_ids = current_user.following_ids.to_set

    @posts = Services::QueryPost.new(params.slice(:q)).search_and_order_with_users( u_ids, params[:page], order_by )
  end

  # 寻车信息点击品牌进入寻车列表页
  def needs_list
    @standard   = Standard.includes(:brands).find_by_id(params[:st])
    @brand      = Brand.includes(:standards).find_by_id(params[:br])
    @car_model  = CarModel.includes(:brand, :standard).find_by_id(params[:cm])

    @standards  = @brand      ? @brand.standards : Standard.all
    @brands     = @standard   ? @standard.brands.valid : Brand.valid
    @standard, @brand = @car_model.standard, @car_model.brand if @car_model
    @car_models = @brand && @standard ? CarModel.where(standard_id: @standard.id, brand_id: @brand.id).valid : []

    @q_json       = {}
    @q_json[:st]  = @standard.id   if @standard
    @q_json[:br]  = @brand.id      if @brand
    @q_json[:cm]  = @car_model.id  if @car_model

    conds = {_type: 1, status: 1}
    conds[:standard_id] = @standard.id  if @standard
    conds[:brand_id]    = @brand.id     if @brand
    conds[:car_model_id]= @car_model.id if @car_model

    @posts = Post.needs.valid.includes(:user, :standard, :brand, :car_model, :base_car).where(conds).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @post     = Post.find_by_id(params[:id])
    @someone  = @post.user
    @follows  = current_user.followings & @someone.followers
    @tender   = Tender.find_by_user_id_and_post_id(current_user.id, @post.id)

    current_user.gen_post_log(@post, 'view')
  end

  def user_list
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    # params[:user_id] 某用户
    params.delete(:action)
    params.delete(:controller)

    @q_json   = params
    @_type    = params[:_type]
    @someone  = User.find_by_id(params[:user_id])
    @brands   = @someone.posts.includes(:brand).where(_type: @_type).map(&:brand).uniq

    conds = {user_id: params[:user_id], _type: params[:_type].to_i, status: 1}
    conds[:brand_id] = params[:br] if params[:br]

    @posts    = Post.includes(:user, :standard, :brand, :car_model, :base_car).where(conds).order(position: :desc).page(params[:page]).per(10)
    @follows  = current_user.followings & @someone.followers
  end

  # 资源表 首页中间最底部的链接
  def user_resources_list
    @users = User.includes(:area).where("id" => Post.resources.valid.includes(:brand).map(&:user_id)).page(params[:page]).per(10)
  end

  # 导出用户资源
  def download_posts
    user = User.find_by_id(params[:user_id])

    path      = "public/system/users_#{params[:user_id]}_resources_list.xls"
    workbook  = WriteExcel.new(path)
    # format
    format    = workbook.add_format(color: 'blue', align: 'center', font: '80')
    worksheet = workbook.add_worksheet

    worksheet.write('A1', "#{user.name}的资源表（下载时间: #{Time.now.strftime("%Y/%m/%d")}）", format)
    worksheet.write('A2', "联系电话: #{user.mobile}", format)
    worksheet.write(2, 0, %w(品牌/车型/款式 外观/内饰 规格/状态 价格 备注))

    user.posts.resources.valid.each_with_index do |record, index|
      worksheet.write(index + 3, 0, record.infos)
    end

    workbook.close

    send_file(path)

    return
  end

  # 报价
  def tender
    post = Post.find_by_id(params[:id])
    params.require(:tender).permit!

    tender = Tender.new(params[:tender])
    tender.post = post
    tender.user = current_user

    tender.save

    redirect_to :back
  end

  # 成交
  def complete
    post   = Post.find_by_id(params[:id])

    tender = post.tenders.find_by_id(params[:tender_id])

    raise 'not found' unless tender

    post.complete(tender.id)

    redirect_to :back
  end

  def my_tender
    @post       = Post.includes(:user).find_by_id(params[:id])
    @someone    = @post.user
    @tender     = Tender.find_by_id(params[:tender_id])

    instrument 'user.has_read_hunt', post_id: @post, user_id: current_user.id
    @follows  = current_user.followings & @someone.followers
  end

  def his_tender
    @post       = Post.includes(:user, :standard, :brand, :car_model, :base_car).find_by_id(params[:id])
    @tender     = Tender.includes(:user).find_by_id(params[:tender_id])
    @someone    = @tender.user

    instrument 'user.has_read_hunt', post_id: @post, user_id: current_user.id
    @follows  = current_user.followings & @someone.followers
  end


  # provide actions(new create edit update) for Staff

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
      user_id:      @someone.id,
      base_car_id:  @user.id,
      method_name:  'outer_color',
      content:      params[:post][:outer_color]
    ) unless base_car.outer_color.include?(params[:post][:outer_color])

    Log::BaseCar.create(
      user_id:      @someone.id,
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

    @post.user = @someone
    @post.channel = 1

    if @post.save
      redirect_to user_list_posts_path(user_id: @someone.id, _type: @post._type)
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
      user_id:      @someone.id,
      base_car_id:  base_car.id,
      method_name:  'outer_color',
      content:      params[:post][:outer_color]
    ) unless base_car.outer_color.include?(params[:post][:outer_color])

    Log::BaseCar.create(
      user_id:      @someone.id,
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
      redirect_to user_list_posts_path(user_id: @someone.id, _type: @post._type)
    else
      render action: edit, flash: @post.errors
    end
  end

end
