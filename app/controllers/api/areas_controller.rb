# encoding: utf-8
# 省市

class Api::AreasController < Api::BaseController

  skip_before_filter :auth_user, only: [:index]

  # 获取省市两级目录
  # Params:
  # Return:
  #   status: 状态码(200)
  #   notice: 消息('success')
  #   data:  返回数据
  # Error:
  #   status: 状态(500)
  #   notice: 消息('failed')
  #   error_msg: 错误信息
  def index
    provinces = Area.includes(:children).provinces
    data = provinces.each_with_object({}) do |p, h|
             h[p.name] = p.children.map(&:as_api)
           end

    render json: { status: 200, notice: 'success', data: data }
  rescue => ex
    render json: { status: 500, notice: 'failure', error_msg: ex.message }
  end

end
