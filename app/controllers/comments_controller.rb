class CommentsController < BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    comment_params[:resource_type] = comment_params[:resource_type].classify
    comment = User.first.comments.new(comment_params)

    if comment.save
      render text: :ok
    end
  rescue => e
    render text: :not_ok
  end

  private

  def comment_params
    # LESLIE: 需要限定 resource_type 么?
    params.require(:comment).permit(:resource_type, :resource_id, :parent_id, :content)
  end

end