# encoding: utf-8

# author: depp.yu
# 评论在databse mapper

class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user, class_name: 'User' # 评论人的id
      t.column :resource_id, :integer # 多态 被评论对象的id
      t.column :resource_type, :string, limit: 30 # 被评论对象的class 这里是string
      t.column :content, :string, limit: 225, null: false # 评论内容
      t.references :parent, class_name: 'Comment' # 自连接
      t.column :status, :integer, default: 0 # 0 未删除 -1 删除
      t.timestamps null: false
    end
  end
end
