# encoding: utf-8

# author: depp.yu
# 通知在database mapper

class CreateNodifications < ActiveRecord::Migration
  def change
    create_table :nodifications do |t|
      t.references :user_id, class_name: 'User' # 被通知人
      t.column :content, :string, limit: 225 # 通知内容
      t.column :status, :integer # 通知状态
      t.column :resource_id, :integer # 多态 object的id
      t.column :resource_type, :string, limit: 30 # object的class 这里是String
      t.timestamps null: false
    end
  end
end
