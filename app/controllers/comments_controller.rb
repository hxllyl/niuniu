class CommentsController < BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    @comment = Comment.new comment_params
    if @comment.save
      respond_to do |format|
        format.html{
          flash[:notice] = t('success')
          redirect_to :back
        }
        format.js {}
      end
    else
      respond_to do |format|
        format.html{
          flash[:error] = @comment.errors.full_messages.join('\n')
          redirect_to :back
        }
        format.js{"alert #{@comment.errors.full_messages.join('\n')}"}
      end
    end
  # rescue => e
  #   render text: :not_ok
  end

  private

  def comment_params
    # LESLIE: 需要限定 resource_type 么?
    params.require(:comment).permit(:resource, :resource_type, :resource_id, :parent_id, :user_id, :content)
  end

end