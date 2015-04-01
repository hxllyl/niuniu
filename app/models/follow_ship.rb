# encoding: utf-8

# author: depp.yu

class FollowShip < ActiveRecord::Base

  # relations
  # 关注我的人
  belongs_to :follower, foreign_key: :follower_id, class_name: 'User'
  # 我关注的人
  belongs_to :following, foreign_key: :following_id, class_name: 'User'
  
end
