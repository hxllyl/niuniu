# encoding: utf-8

module PostHelper
  def following?(user)
    current_user && current_user.following?(user) ? '已关注' : '未关注'
  end
end
