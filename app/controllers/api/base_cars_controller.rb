# encoding: utf-8
# 取基本库用于创建跟筛选条件
class Api::BaseCarsController < Api::BaseController

  # 取基本资料
  #
  # Params:
  #   token:        [String]    valid token
  #   updated_at:   [DataTime]  最后更新时间
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    car_infos and updated_at
  # Error
  #  status: [Integer] 400

  #  notice: [String]  请重试
  def index
    newest_updated_at = [Standard.pluck(:updated_at), Brand.pluck(:updated_at), BaseCar.pluck(:updated_at)].flatten.max
    last_updated_at = params[:updated_at] ? DateTime.parse(params[:updated_at]) : DateTime.now.ago(1.years)

    data = if newest_updated_at > last_updated_at
             {
                 car_infos: Standard.includes(brands: [:car_photo, :base_cars]).map(&:to_hash),
                 updated_at: newest_updated_at
             }
           else
             {tag: 'Already up-to-date'}
           end

    render json: {status: 200, notice: 'success', data: data}

  rescue => e
    render json: {status: false, error: e.message}
  end

end
