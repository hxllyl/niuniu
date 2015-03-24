# encoding: utf-8

class UsersController < ApplicationController
  def edit
  end

  def update
  end

  def show
    @uncompleted_posts = current_user.posts.needs.where(status: 1).order(updated_at: :desc).page(params[:page]).per(10)
    @completed_posts   = current_user.posts.needs.completed.order(updated_at: :desc).page(params[:page]).per(10)
    @done_months       = current_user.posts.needs.where("updated_at >= ?", 3.months.from_now)
  end

  def my_tenders
  end

  def my_followers
  end

  def system_infos
  end

  def my_level
  end

  def edit_my_level
  end

  def update_my_level
  end

  def about_us
  end
  
  private
  
end
