# encoding: utf-8

#author: depp.yu
#投诉在database mapper

class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.column :resource_id, :integer # 多态 被投诉对象的id
      t.column :resource_type, :string, limit: 30 # 被投诉对象的class，在这里是字符串
      t.references :user, class_name: 'User', null: false # 投诉人
      t.column :status, :integer, default: 0 # 0 未处理 1 已处理
      t.column :content,:string, limit: 225 # 评论内容
      t.references :operator, class_name: 'User' # 操作人
      t.timestamps null: false
    end

    add_index(:complaints, [:resource_id, :resource_type])
    add_index(:complaints, :user_id)
    add_index(:complaints, :operator_id)
  end
end
