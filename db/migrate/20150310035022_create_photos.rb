# encoding: utf-8

# author: depp.yu
# 图片类在database mapper photo模型管理所有系统的中的图片

class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.column :owner_id, :integer # 所属object的id 多态
      t.column :owner_type, :string, limit: 20 # 所属object的class_name 在这里是个string
      t.column :image, :string, limit: 60 # 图片的路径
      t.column :_type, :string, limit: 30 # 图片的种类 例如：avatar
      t.column :mask, :string, limit: 10 # 却别用户 继承关系
      t.timestamps null: false
    end
  end
end
