# encoding: utf-8
# banners
class Api::BannersController < Api::BaseController

  # 获取 banner
  #
  # Params:
  #   token:                      [String]  valid token
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data: [Array]
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def index
    banners = Banner.valid
    render json: { status: 200, notice: 'success', data: {  banners: banners.map(&:to_hash) } }
  rescue => e
    render json: { status: 200, notice: 'failed' }
  end

end
