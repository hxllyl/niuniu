# encoding: utf-8
# Helpers
class Api::HelpersController < Api::BaseController

  skip_before_action :auth_user
  skip_before_action :authenticate_user!

  # 获取 Helpers
  #
  # Params:
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data: [Array]
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def index
    helpers = Helper.all
    render json: { status: 200, notice: 'success', data: {  helpers: helpers.map(&:to_hash) } }
  # rescue => e
  #   render json: { status: 200, notice: 'failed' }
  end

end