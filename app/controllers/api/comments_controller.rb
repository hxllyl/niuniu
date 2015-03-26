# encoding: utf-8
# 评论
class Api::CommentsController < Api::BaseController

  # 某对象的评论列表
  #
  # Params:
  #   token:             [String]  valid token
  #   resource_type:     [String]  评论对象类型
  #   resource_id:       [Integer] 评论对象的ID
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  #   data:   [JSON]    comments and replies list
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def list
    raise 'resource_type and resource_id must be present' unless params[:resource_type] && params[:resource_id]

    infos = Comment.where(resource_type: params[:resource_type], resource_id: params[:resource_id]).order(updated_at: :desc).map(&:to_hash)

    render json: {status: 200, notice: 'success', data: {comments: infos}}

    rescue => e
    render json: {status: false, error: e.message}
  end

  # 新建评论
  #
  # Params:
  #   token:                      [String]  valid token
  #   comment[resource_type]:     [String]  评论对象类型
  #   comment[resource_id]:       [Integer] 评论对象的ID
  #   comment[content]:           [String]  评论内容
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def create
    ele = params[:comment][:resource_type].classify.constantize.find_by_id(params[:comment][:resource_id])

    raise 'not found' unless ele

    params.require(:comment).permit!

    comment = Comment.new(params[:comment].merge(user_id: @user.id))

    if comment.save
      render json: {status: 200, notice: 'success'}
    else
      render json: {status: 400, notice: '请重新再试'}
    end

    rescue => e
    render json: {status: false, error: e.message}
  end


  # 回复
  #
  # Params:
  #   token:                [String]  valid token
  #   comment[parent_id]:   [Integer] 回复评论的 ID
  #   comment[content]:     [String]  评论内容
  #
  # Return:
  #   status: [Integer] 200
  #   notice: [String]  success
  # Error
  #   status: [Integer] 400
  #   notice: [String]  请重新再试
  def reply
    ele = Comment.find_by_id(params[:comment][:parent_id])

    raise 'not found' unless ele

    params.require(:comment).permit!

    reply = Comment.new(params[:comment].merge(user_id: @user.id))

    if reply.save
      render json: {status: 200, notice: 'success'}
    else
      render json: {status: 400, notice: '请重新再试'}
    end

    rescue => e
    render json: {status: false, error: e.message}
  end

end
