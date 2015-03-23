class FollowShipsController < BaseController

  # skip_before_action :verify_authenticity_token
  # skip_before_action :authenticate_user!

  def create
    user = User.find(follow_ship_params[:user_id])
    current_user.followings << user
    current_user.save

    render text: :ok
  rescue => e
    render text: e.message
  end

  def destroy
    fs = FollowShip.find(follow_ship_params[:id])
    fs.delete

    render text: :ok
  rescue => e
    render text: e.message
  end

  private

  def follow_ship_params
    params[:follow_ship].permit(:user_id, :id)
  end

end