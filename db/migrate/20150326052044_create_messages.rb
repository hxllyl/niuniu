# encoding: utf-8

# 消息类型
class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.column :title,  :string, limit: 100 # 消息标题
      t.references :sender, class_name: 'User', null: false # 消息发送人
      t.references :receiver, class_name: 'User', null: false # 消息接受人
      t.column :_type, :integer, default: 0 # 消息类型
      t.column :content, :string, null: false # 消息内容
      t.column :status, :integer, default: 0 # 消息状态
      t.timestamps null: false
    end

    add_index(:messages, :sender_id)
    add_index(:messages, :receiver_id)
    add_index(:messages, :_type)
    add_index(:messages, :status)
  end
end
