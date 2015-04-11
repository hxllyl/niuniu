# encoding: utf-8
class FollowShipsController < BaseController

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
