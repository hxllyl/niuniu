# encoding: utf-8

# author: depp.yu

class FollowShip < ActiveRecord::Base
  
  # relations
  belongs_to :follower, foreign_key: :follower_id, class_name: 'User'
  belongs_to :following, foreign_key: :following_id, class_name: 'User'
end
