# encoding: utf-8

class CreateLogContactPhones < ActiveRecord::Migration
  def change
    create_table :log_contact_phones do |t|
      t.column :mobile, :string, limit: 15, null: false, unique: true # 手机号必须存在，且唯一
      t.references :sender, class_name: 'User', null: false # 发送人
      t.column :_type, :integer, default: 0 # 区分用户发送还是客服发送 0 客服 1 用户
      t.column :is_register, :boolean, default: false # 是否注册
      t.column :last_contact_at, :datetime # 最后一次联系时间
      t.column :status, :integer
      t.timestamps null: false
    end

    add_index(:log_contact_phones, :mobile)
    add_index(:log_contact_phones, :sender_id)
    add_index(:log_contact_phones, :_type)
  end
end
