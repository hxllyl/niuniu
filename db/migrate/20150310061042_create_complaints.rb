# encoding: utf-8

#author: depp.yu
#投诉在database mapper

class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.column :resource_id, :integer # 多态 被投诉对象的id
      t.column :resource_type, :string, limit: 30 # 被投诉对象的class，在这里是字符串
      t.references :user, class_name: 'User' # 投诉人
      t.column :status, :integer, default: 0 # 0 未审核 1 审核
      t.timestamps null: false
    end
  end
end
