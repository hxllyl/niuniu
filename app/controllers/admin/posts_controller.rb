class Admin::PostsController < Admin::BaseController

  def index
    @posts = Post.all.includes(:user).order('created_at desc').page(params[:page]||1).per(30)
  end

end
