# encoding: utf-8
# 市场资源，寻车信息
class Api::PostsController < Api::BaseController

  # 市场资源列表，寻车列表
  #
  # Params:
  #   token:        [String]    valid token
  #   _type:        [Integer]   0 资源 1 寻车
  #   updated_at:   [DataTime]  更新时间，每次返回最新的更新时间
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    posts json
  # Error
  #   status: [Integer] 400
  #   Notice: [String]  请重新再试
  def list
    conds = {_type: params[:_type]}
    conds.merge!(:updated_at.gt => DateTime.parse(params[:updated_at])) if params[:updated_at]
    posts = Post.where(conds).order(updated_at: :desc)

    render json: {status: 200, notice: 'success', data: {posts: posts.map(&:to_hash)}}
  end

  # 我的资源列表，寻车列表
  #
  # Params:
  #   token:        [String]    valid token
  #   _type:        [Integer]   0 资源 1 寻车
  #   updated_at:   [DataTime]  更新时间，每次返回最新的更新时间
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

    render json: {status: 200, notice: 'success', data: {posts: posts.map(&:to_hash)}}
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
  #   post[car_license_areas]:  [String]      上牌区域
  #   post[car_in_areas]:       [Array]       车辆所在地
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

      params[:post][:car_model_id] = car_model.id
      params[:post][:base_car_id]  = base_car.id

    params.require(:post).permit!

    post = Post.new(params[:post])
    post.user = @user

    if post.save
      render json: {status: 200, notice: 'success', data: {post: post.to_hash}}
    else
      render json: {status: 400, notice: 'failure', data: {errors: post.errors}}
    end

  end

  # 报价
  #
  # Params:
  #   token:                      [String]    valid token
  #   tender[:post_id]:           [Integer]   post ID
  #   tender[:discount_way]:      [Integer]   报价方式
  #   tender[:discount_content]:  [Float]     报价详情
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
      render json: {status: 400, notice: '请重试'}
    end

    # rescue => e
    # render json: {status: false, error: e.message}
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
end
