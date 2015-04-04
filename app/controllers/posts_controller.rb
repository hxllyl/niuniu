# encoding: utf-8

require_relative '../../app/services/search_resource'
require_relative '../../app/services/list_resources'

class PostsController < ApplicationController
   skip_before_filter :verify_authenticity_token, only: [:tender, :complete]

  def index
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车

    @_type      = params[:_type]
    @standards  = Standard.all
    @brands     = Brand.order(click_counter: :desc).limit(20)
    @car_models = CarModel.order(click_counter: :desc).limit(40)
    posts   = Post.includes(:base_car, :post_photos, :standard, :brand).where(_type: params[:_type]).order(updated_at: :desc).group_by(&:user_id).collect{|k, v| v.first}
    @posts  =  Kaminari.paginate_array(posts).page(params[:page]).per(10)
  end

  # 市场资源点击品牌进入资源列表页
  # params: st=1&br=1&cm=1&bc=1&oc=xx&ic=xx&rt=xx
  def resources_list
    if params[:bc]
      @base_car  = BaseCar.find_by_id(params[:bc])
      @car_model, @brand, @standard = @base_car.car_model, @base_car.brand, @base_car.standard
      @base_cars, @car_models, @brands, @standards = @car_model.base_cars, @brand.car_models, @standard.brands, @brand.standards
      @q_json = {bc: @base_car.id, cm: @car_model.id, br: @brand.id, st: @standard.id}
    elsif params[:cm]
      @q_json = {cm: params[:cm]}
      @base_car = nil
      @car_model = CarModel.find_by_id(params[:cm])
      @brand, @standard, @base_cars = @car_model.brand, @car_model.standard, @car_model.base_cars
      @car_models, @brands, @standards  = CarModel.where(standard_id: @standard.id, brand_id: @brand.id), @standard.brands, @brand.standards
      @q_json = {cm: @car_model.id, br: @brand.id, st: @standard.id}
    elsif params[:br] && params[:st]
      @q_json = {st: params[:st], br: params[:br]}
      @brand = Brand.find_by_id(params[:br])
      @standard = Standard.find_by_id(params[:st])
      @car_model, @base_car, @base_cars = nil, nil, []
      @car_models = CarModel.where(standard_id: @standard.id, brand_id: @brand.id)
      @brands, @standards = @standard.brands, Standard.all
      @q_json = {br: @brand.id, st: @standard.id}
    elsif params[:br]
      @q_json = {br: params[:br]}
      @base_car, @car_model, @base_cars, @car_models = nil, nil, [], []
      @brand = Brand.find_by_id(params[:br])
      @brands, @standards  = Brand.all, @brand.standards
      @q_json = {br: @brand.id}
    elsif params[:st]
      @q_json = {st: params[:st]}
      @base_car, @car_model, @brand, @base_cars, @car_models = nil, nil, nil, [], [],[]
      @standard = Standard.find_by_id(params[:st])
      @brands, @standards  = @standard.brands, Standard.all
      @q_json = {st: @standard.id}
    else
      @standard, @brand, @car_model, @base_car, @car_models, @base_cars = nil, nil, nil, nil, [], []
      @standards, @brands = Standard.all, Brand.all
      @q_json = {}
    end

    if @base_car
      conds = {}
      conds[:outer_color]   = params[:oc] && @q_json[:oc] = params[:oc]  if params[:oc]
      conds[:inner_color]   = params[:ic] && @q_json[:ic] = params[:ic]  if params[:ic]
      conds[:resource_type] = params[:rt] && @q_json[:rt] = params[:rt]  if params[:rt]
      @order_ele = params[:order_by] ? Post::ORDERS[params[:order_by].to_sym] : nil
      @order_by = params[:order_by] == 'expect_price' ? {expect_price: :asc} : {updated_at: :desc}
      @posts = @base_car.posts.resources.where(conds).order(@order_by).page(params[:page]).per(10)
    end
  end

  # 一键找车列表页
  def key_search
    params.delete(:action)
    params.delete(:controller)

    @q_json             = params
    @q_json[:order_ele] = params[:order_ele] ? params[:order_ele] : 'updated_at'
    # u_ids      = User.all.map(&:id)

    # followed, unfollow = if current_user
    #                       [current_user.followings.map(&:id), u_ids - current_user.followings.map(&:id)]
    #                     else
    #                       [[], u_ids]
    #                     end

    # @followed_posts =   Post.search do
    #                       with(:_type, 0)
    #                       fulltext String(params[:q])
    #                       with(:user_id, Array(followed))
    #                       fulltext String(params[:q])
    #                       order_by(:updated_at, :desc)
    #                     end.results

    # @unfollow_posts =   Post.search do
    #                       with(:_type, 0)
    #                       fulltext String(params[:q])
    #                       with(:user_id, Array(unfollow))
    #                       fulltext String(params[:q])
    #                       order_by(:updated_at, :desc)
    #                     end.results
    # @posts = Kaminari.paginate_array(@followed_posts + @unfollow_posts).page(params[:page]).per(10)
    @posts = Post.resources.valid.page(params[:page]).per(10)
  end

  # 寻车信息点击品牌进入寻车列表页
  def needs_list
    # @rs = SearchResource.new(params)
    # @needs = if @rs.car_model.present?
    #            @rs.car_model.posts.needs
    #          elsif @rs.brand.present?
    #            Post.needs.with_brand(@rs.brand)
    #          elsif @rs.standard.present?
    #            Post.with_standard(@rs.standard).needs
    #          else
    #            Post.needs
    #          end

    @standard   = Standard.find_by_id(params[:st])
    @brand      = Brand.find_by_id(params[:br])
    @car_model  = CarModel.find_by_id(params[:cm])

    if @car_model
      @standard, @brand = @car_model.standard, @car_model.brand
      @car_models = CarModel.where(standard_id: @car_model.standard_id, brand_id: @car_model.brand_id)
      @standards, @brands = @brand.standards, @standard.brands
      @q_json = {cm: @car_model.id, br: @brand.id, st: @standard.id}
    elsif @standard && @brand
      @standards, @brands = @brand.standards, @standard.brands
      @car_model, @car_models = nil, CarModel.where(standard_id: @standard.id, brand_id: @brand.id)
      @q_json = {br: @brand.id, st: @standard.id}
    elsif @standard
      @standards, @brands, @car_models, @brand, @car_model = Standard.all, @standard.brands, [], nil, nil
      @q_json = {st: @standard.id}
    elsif @brand
      @standards, @brands, @car_models, @standard, @car_model = @brand.standards, Brand.all, [], nil, nil
      @q_json = {br: @brand.id}
    else
      @standards, @brands, @car_models = Standard.all, Brand.all, CarModel.all.sample(30)
      @q_json = {}
    end

    conds = {_type: 1}
    conds[:standard_id] = @standard.id  if @standard
    conds[:brand_id]    = @brand.id     if @brand
    conds[:car_model_id]= @car_model.id if @car_model
    @order_ele = params[:order_by] ? Post::ORDERS[params[:order_by].to_sym] : nil
    @order_by = params[:order_by] == 'expect_price' ? {expect_price: :asc} : {updated_at: :desc}
    @posts = Post.where(conds).order(@order_by).page(params[:page]).per(10)
  end

  def show
    @post       = Post.includes(:comments, :tenders).find_by_id(params[:id])
    @someone    = @post.user || NullObject.new
    @title      = '寻车详情'
    @tender     = if !params[:tender_id] && current_user
                    Tender.where(user_id: current_user.id, post_id: @post.id).first
                  else
                    Tender.find_by_id(params[:tender_id])
                  end
    if params[:tender_id]
      @tender   = Tender.find_by_id(params[:tender_id])
      if current_user
        if current_user.id == @tender.user_id
          @title    = '我的报价'

        else
          @title    = '他的报价'
          @someone  = @tender.user
        end
      end

      instrument 'user.has_read_hunt', post_id: @post, user_id: current_user.id
    end
    @follows  = current_user.followings & @someone.followers if current_user
  end

  def user_list
    # params[:_type] 资源类型 0 => 资源， 1 => 寻车
    # params[:user_id] 某用户
    params.delete(:action)
    params.delete(:controller)

    @q_json   = params
    @_type    = params[:_type]
    @someone  = User.find_by_id(params[:user_id])
    @brands   = @someone.posts.resources.map(&:brand).uniq

    conds            = {user_id: params[:user_id], _type: params[:type].to_i}
    conds[:brand_id] = params[:br] if params[:br]

    @posts    = Post.where(conds).order(position: :desc).page(params[:page]).per(10)
    @follows  = current_user.followings & @someone.followers if current_user
  end

  # 资源表 首页中间最底部的链接
  def user_resources_list
    @users = User.where("id" => Post.resources.map(&:user_id)).page(params[:page]).per(10)
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

    user.posts.resources.order(updated_at: :desc).each_with_index do |record, index|
      worksheet.write(index + 3, 0, record.to_ary)
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


end
