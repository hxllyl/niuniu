# encoding: utf-8
# 取基本库用于创建跟筛选条件
class Api::BaseCarsController < Api::BaseController

  # 取基本资料
  #
  # Params:
  #   token:        [String]    valid token
  #   _type:        [String]    类型 standard, brand, car_model, base_car
  #   standard_id:  [Integer]   上一级类型ID, 找车型（car_model）时需要brand_id(id) 跟standard_id
  #   id:           [Integer]   类型的ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    children
  # Error
  #  status: [Integer] 400

  #  notice: [String]  请重试
  def index
    # newest_updated_at = [Standard.pluck(:updated_at), Brand.pluck(:updated_at), BaseCar.pluck(:updated_at)].flatten.max
    # last_updated_at = params[:updated_at] ? DateTime.parse(params[:updated_at]) : DateTime.now.ago(1.years)

    # data = if newest_updated_at > last_updated_at
    #          {
    #              car_infos: Standard.includes(brands: [:car_photo, :car_models, :base_cars]).map(&:to_hash),
    #              updated_at: newest_updated_at
    #          }
    #        else
    #          {tag: 'Already up-to-date'}
    #        end
    data =  case params[:_type]
            when 'standard'
              Standard.all.map(&:to_hash)
            when 'brand'
              Standard.find_by_id(params[:id]).brands.map(&:to_hash)
            when 'car_model'
              CarModel.where(standard_id: params[:standard_id], brand_id: params[:id]).valid.map(&:to_hash)
            when 'base_car'
              CarModel.find_by_id(params[:id]).base_cars.valid.map(&:to_hash)
            end

    render json: {status: 200, notice: 'success', data: data}

  rescue => e
    render json: {status: false, error: e.message}
  end

end
