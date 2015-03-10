# encoding: utf-8

# author: depp.yu
# 历史浏览记录在database mapper

class CreateHistoryLists < ActiveRecord::Migration
  def change
    create_table :history_lists do |t|
      t.references :user_id, class_name: 'User' # 浏览人
      t.column :resource_id, :integer # 多态 被浏览对象的id
      t.column :resource_type, :string, limit: 30 # 被浏览对象的class 这里是string  
      t.timestamps null: false
    end
  end
end
