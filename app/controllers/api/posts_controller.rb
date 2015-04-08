# encoding: utf-8
# 市场资源，寻车信息
require_relative '../../../app/services/query_posts'
class Api::PostsController < Api::BaseController

       # skip_before_action :auth_user, only: [ :search ]

  # 市场资源列表，寻车列表
  #
  # Params:
  #   token:        [String]    valid token
  #   _type:        [Integer]   0 资源 1 寻车
  #   page:         [Integer]   页码 # 从0开始
  #   per:          [Integer]   每页记录数
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    posts json
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def list
    conds = {_type: params[:_type], status: 1 }

    page = params[:page] ? params[:page] : 1
    per  = params[:per]  ? params[:per]  : 10
    posts = Post.where(conds).order(updated_at: :desc).page(page).per(per)

    data = posts.map { |post| post.to_hash.merge!( is_following: @user.following?(post.user) ) }
    render json: {status: 200, notice: 'success', data: { posts: data } }
  end

  # 我的资源列表，寻车列表
  #
  # Params:
  #   token:        [String]    valid token
  #   _type:        [Integer]   0 资源 1 寻车
  #
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    my_posts json
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def my_list

    posts = @user.posts.where(_type: params[:_type]).order(updated_at: :desc)

    if params[:_type] == '1' # 仅针对寻车
      instrument 'user.has_read_tender', post_id: posts.pluck(:id)
    end

    render json: {status: 200, notice: 'success', data: {posts: posts.map(&:to_hash)}}
  end

  # 我的报价列表
  #
  # Params:
  #   token:        [String]    valid token
  #   page:         [Integer]   页码 # 从0开始
  #   per:          [Integer]   每页记录数
  #
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    uncompleted and completed json
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def my_tenders
    page = params[:page] ? params[:page] : 1
    per  = params[:per]  ? params[:per]  : 10

    u_c = @user.tenders.completed
    uncompleted = @user.tenders.uncompleted.order(updated_at: :desc).page(page).per(per).map(&:to_hash)
    completed   = u_c.order(updated_at: :desc).page(page).per(per).map(&:to_hash)

    post_ids = u_c.pluck(:post_id)
    instrument 'user.has_read_hunt', post_id: post_ids, user_id: @user.id do
      render json: {status: 200, notice: 'success', data: {uncompleted: uncompleted, completed: completed}}
    end

    rescue => e
    render json: {status: false, error: e.message}
  end

  # 他的资源列表，寻车列表
  #
  # Params:
  #   token:        [String]    valid token
  #   user_id:      [Integer]   user ID
  #   _type:        [Integer]   0 资源 1 寻车
  #   page:         [Integer]   页码 # 从0开始
  #   per:          [Integer]   每页记录数
  #
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    his_posts json
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def user_list
    user = User.find_by_id(params[:user_id])

    raise 'not found' unless user

    page = params[:page] ? params[:page] : 1
    per  = params[:per]  ? params[:per]  : 10

    posts = user.posts.where(_type: params[:_type]).page(page).per(per)

    render json: {status: 200, notice: 'success', data: {posts: posts.map(&:to_hash)}}

    rescue => e
    render json: {status: false, error: e.message}
  end

  # 单独的资源，寻车
  #
  # Params:
  #   token: [String]  valid token
  #   _type: [Integer] 0|1
  #   id   : [Integer] post ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    post json
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def show
    type = params[:_type]
    post = Post.find_by_id(params[:id])
    if post
      render json: {status: 200, data: {post: post.to_hash}}
    else
      render json: {status: 200, notice: 'not_found', data: {}}
    end
  end

  # 创建资源或寻车
  #
  # Params:
  #   token:                    [String]      valid token
  #   post[_type]:              [Integer]     类型 0 资源 1 寻车
  #   post[resource_type]:      [Integer]     资源类型(只有资源有) 0 现车 1 期货
  #   post[standard_id]:        [Integer]     规格 ID select
  #   post[brand_id]:           [Integer]     品牌 ID select
  #   post[car_model_id]:       [Integer]     车型
  #   post[outer_color]:        [String]      外观颜色
  #   post[inner_color]:        [String]      内饰颜色
  #   post[base_car_id]:        [Integer]     基本库 ID 匹配
  #   post[car_license_area]:   [String]      上牌区域
  #   post[car_in_area]:        [Array]       车辆所在地
  #   post[take_car_date]:      [Integer]     提车日期 select
  #   post[discount_way]:       [Integer]     出价方式(电议只有资源有) select
  #   post[discount_content]:   [Float]       出价详情
  #   post[post_photos]:        [File Array]  资源图片
  #   post[remark]:             [String]      备注
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    post attrs
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  failure
  #   data:   [JSON]    post errors
  def create
    params.require(:post).permit!

    post      = Post.find_or_initialize_by(id: params[:post][:id])
    standard  = Standard.find_by_id(params[:post][:standard_id])
    brand     = Brand.find_by_id(params[:post][:brand_id])
    car_model = CarModel.find_by_id(params[:post][:car_model_id])
    base_car  = BaseCar.find_by_id(params[:post][:base_car_id])

    car_model = CarModel.create(
                  standard_id:  standard.id,
                  brand_id:     brand.id,
                  name:         params[:post][:car_model_id],
                  status:       0
                ) unless car_model

    base_car  = BaseCar.create(
                  standard_id:  standard.id,
                  brand_id:     brand.id,
                  car_model_id: car_model.id,
                  style:        params[:post][:base_car_id],
                  outer_color:  [params[:post][:outer_color]],
                  inner_color:  [params[:post][:inner_color]],
                  status: 0
                ) unless base_car

    params[:post][:car_model_id] = car_model.id
    params[:post][:base_car_id]  = base_car.id

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

    photos = {}
    aa = params[:post].delete(:post_photos)
    aa && aa.each do |ele|
      photos[ele['_type']] = params.delete(ele['_type'])
    end
    post.attributes = params[:post]
    # 资源传图
    photos && photos.each do |k, v|
      if v
        post.post_photos.new(_type: k, image: v.tempfile)
      else
        post.post_photos.where(_type: k).delete_all
      end
    end

    post.user = @user

    if post.save
      render json: {status: 200, notice: 'success', data: {post: post.to_hash}}
    else
      render json: {status: 400, notice: 'failure', data: {errors: post.errors}}
    end
  rescue => e
    render json: {status: 400, notice: 'failure', data: {errors: e.errors}}
  end

  # 报价
  #
  # Params:
  #   token:                     [String]    valid token
  #   tender[post_id]:           [Integer]   post ID
  #   tender[discount_way]:      [Integer]   报价方式
  #   tender[discount_content]:  [Float]     报价详情
  #   tender[remark]:            [String]    备注
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def tender
    post = Post.find_by_id_and__type(params[:tender][:post_id], 1)

    raise 'not found' unless post

    params.require(:tender).permit!
    tender = Tender.new(params[:tender].merge(user_id: @user.id))

    if tender.save
      render json: {status: 200, notice: 'success', data: {tender: tender}}
    else
      render json: {status: 400, notice: 'failure'}
    end

  rescue => e
    render json: {status: false, error: e.message}
  end

  # 成交寻车
  #
  # Params:
  #   token:    [String]    valid token
  #   post_id:  [Integer]   post ID
  #   tender_id:[Integer]   tender ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def complete
    post = @user.posts.needs.find_by_id(params[:post_id])

    raise 'not found' unless post

    tender = post.tenders.find_by_id(params[:tender_id])

    raise 'not found' unless tender

    post.complete(tender.id)

    render json: {status: 200, notice: 'success', data: {post: post, tender: tender}}
  end

  # 撤销我的报价
  #
  # Params:
  #   token:    [String]    valid token
  #   id:       [Integer]   tender ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def del_my_tender
    tender = Tender.find_by_id(params[:id])

    raise 'not found' unless tender
    raise 'you have no right to do it!' unless tender.user == @user

    tender.update_attributes(status: -1)


    render json: {status: 200, notice: 'success'}
    rescue => e
    render json: {status: false, error: e.message}
  end

  # 资源更新
  #
  # Params:
  #   token:    [String]    valid token
  #   post_ids: [Array]     资源的id
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息

  def update_all
    if @user.could_update_my_resoruces?
      posts = @user.posts.resources.where("id in (?)", params[:post_ids])
      posts.update_all(updated_at: Time.now)
      @user.gen_update_all_log
      render_infos = { status: 200, notice: 'success' }
    else
      render_infos = { status: 200, notice: 'faild', error_msg: '对不起，您一个小时之内不能重复更新您的资源列表' }
    end
    render json: render_infos
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message}
  end

  # 资源上移，下移
  #
  # Params:
  #   token:    [String]    valid token
  #   id:       [Integer]     资源的id
  #   swap_id:  [Integer]  所要换位的resource 的id 上移就是上一个的resource的id 下移 就是下一个的resource的id
  #   way:      [String]  up 或者 down
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息

  def change_position
    resource = @user.posts.resources.find_by_id params[:id]

    swap_resource = @user.posts.resources.find_by_id params[:swap_id]

    raise 'user did not had the resource' if resource.blank? or swap_resource.blank?

    unless (params[:way] == 'down' and resource.first?) or ( params[:way] == 'up' and resource.last?)
      swap_tmp(resource, swap_resource)
      resource.save
      swap_resource.save
    end

    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message}
  end

  # 删除资源
  #
  # Params:
  #   token:    [String]    valid token
  #   id:       [Integer]     资源的id
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息

  def destroy
    resource = @user.posts.resources.find_by_id params[:id]
    raise 'user did not had the resource' if resource.blank?

    @user.posts.resources.delete resource
    render json: { status: 200, notice: 'success' }
  rescue => ex
    render json: { status: 500, notice: 'failed', error_msg: ex.message}
  end


  # 资源搜索
  #
  # Params:
  #   token:    [String]    valid token
  #   type:     [Integer]   搜索类型 0(模糊搜索), 1(级联搜索)
  #   q:        [String]    模糊搜索时候的关键词
  #   cid:      [Integer]   车型id
  #   sid:      [Integer]   规格id
  #   bid:      [Integer]   品牌id
  #   style:    [String]    款式
  #   icol:     [String]    内饰
  #   ocol:     [String]    外观
  #   status:   [Integer]   resource_type 期货还是现车
  # Return:
  #   status:   [Integer] 200
  #   notice:   [String]  success
  #   data:     [JSON]    posts json
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息
  def search
    my_following_ids = @user.following_ids.to_set

    results = if params[:cid] && params[:style] # 认定为级联搜索
                cond = params.slice(:cid, :icol, :ocol, :style, :status)
                Services::QueryPost.new(cond).by_style_and_status_color
              elsif params[:q]
                Services::QueryPost.new(params.slice(:q)).search_and_order_with_users(my_following_ids, params[:page])
              else
                Post.none
              end

    data = Array(results).map { |post| post.to_hash.merge!(is_following: my_following_ids.include?(post.user_id)) }

    render json: {status: 200, notice: 'success', data: {posts: data}}
  rescue => ex
    render json: {status: 500, notice: 'failed', error_msg: ex.message}
  end

  # 我针对某条寻车是否报过价
  #
  # Params:
  #   token:    [String]    valid token
  #   post_id:  [Integer]   寻车ID
  #
  # Return:
  #   status:   [Integer] 200
  #   notice:   [String]  success
  #   data:     [JSON]    is_tenderd(true|false) and tender_status(nil|未成交|已成交|已撤销)
  #
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息
  def tender_status
    post = Post.find_by_id(params[:post_id])
    raise '寻车信息出错' if post._type != 1

    tender = post.tenders.find_by_user_id(@user.id)

    is_tenderd, tender_status = tender ? [true, Tender::STATUS[tender.status]] : [false, nil]

    render json: {status: 200, notice: 'success', data: {is_tenderd: is_tenderd, tender_status: tender_status}}

  rescue => e
    render json: {status: 500, notice: 'failed', error_msg: e.message}
  end


  # 所有品牌
  #
  # Params:
  #   token:    [String]    valid token
  #
  # Return:
  #   status:   [Integer] 200
  #   notice:   [String]  success
  #   data:     [JSON]    brand_names => %w[奥迪 宝马]
  #
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息
  def filter_brands
    brands = Brand.distinct(:name).pluck(:name)
    render json:  { status: 200, notice: 'success', data: { brand_names: brands } }
  rescue => e
    render json: { status: 500, notice: 'failed', error_msg: e.message }
  end


  # 根据品牌名称搜索寻车
  #
  # Params:
  #   token:              [String]    valid token
  #   brand_name:          [String]   品牌名称
  #   page:                [Integer]   页数
  #
  # Return:
  #   status:   [Integer] 200
  #   notice:   [String]  success
  #   data:     [JSON]    posts => [post1, post2]
  #
  # Error
  #   status: [Integer] 500
  #   notice: [String]  failed
  #   error_msg: 错误信息
  def filter_brand
    hunts = Post.needs.includes(:user, :brand).where("brands.name" => String(params[:brand_name])).page(params[:page] || 1).per(10)
    data = Array(hunts).map { |post| post.to_hash }

    render json: {status: 200, notice: 'success', data: { posts: data  } }
  rescue => e
    render json: { status: 500, notice: 'failed', error_msg: e.message }
  end

  private

  def swap_tmp(objx, objy, temp=nil)
    temp = objx.position
    objx.position = objy.position
    objy.position = temp
  end

end
