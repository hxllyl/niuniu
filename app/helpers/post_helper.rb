# encoding: utf-8

module PostHelper

  def following?(user)
    current_user && current_user.following?(user) ? '已关注' : ''
  end

  def resource_name(post)
    "#{post.brand_name} #{post.car_model_name} #{post.base_car_NO}"
  end
end
