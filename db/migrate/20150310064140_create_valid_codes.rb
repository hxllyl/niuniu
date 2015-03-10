# encoding: utf-8

# author: depp.yu
# 手机验证码在database mapper

class CreateValidCodes < ActiveRecord::Migration
  def change
    create_table :valid_codes do |t|
      t.column :mobile, :string, limit: 15, null: false # 关联手机
      t.column :code, :string, limit: 10, null: false # 验证码
      t.column :_type, :integer # 验证码用于什么用途
      t.column :status, :integer # 验证码状态   
      t.timestamps null: false
    end
  end
end
