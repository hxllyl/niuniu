# encoding: utf-8

# author: depp.yu
# 关注关系在database mapper

class CreateFollowShips < ActiveRecord::Migration
  def change
    create_table :follow_ships do |t|
      t.references :follower, class_name: 'User' # 关注人的id
      t.references :following, class_name: 'User' # 被关注人的id
      t.timestamps null: false
    end
  end
end
