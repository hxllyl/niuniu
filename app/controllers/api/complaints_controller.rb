# encoding: utf-8
# 投诉
class Api::ComplaintsController < Api::BaseController

  # 新建投诉
  #
  # Params:
  #   token:                      [String]  valid token
  #   complaint[resource_type]:   [String]  投诉对象类型
  #   complaint[resource_id]:     [Integer] 投诉对象的ID
  #   complaint[content]:         [String]  投诉内容
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def create
    ele = params[:complaint][:resource_type].classify.constantize.find_by_id(params[:complaint][:resource_id])

    raise 'not found' unless ele

    params.require(:complaint).permit!

    complaint = @user.complaints.new(params[:complaint])

    if complaint.save
      render json: {status: 200, notice: '已投诉，请等待客服处理，谢谢'}
    else
      render json: {status: 400, notice: '请重新再试'}
    end

    rescue => e
    render json: {status: false, error: e.message}
  end

end
