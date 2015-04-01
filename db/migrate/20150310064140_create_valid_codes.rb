# encoding: utf-8

# author: depp.yu
# 手机验证码在database mapper

class CreateValidCodes < ActiveRecord::Migration
  def change
    create_table :valid_codes do |t|
      t.column :mobile, :string, limit: 15, null: false # 关联手机
      t.column :code, :string, limit: 10, null: false # 验证码
      t.column :_type, :integer # 验证码用于什么用途
      t.column :status, :integer, default: 0 # 验证码状态 0 未使用 1 已使用   
      t.timestamps null: false
    end
    
    add_index(:valid_codes, :mobile)
    add_index(:valid_codes, :_type)
    add_index(:valid_codes, :code)
    add_index(:valid_codes, :status)
  end
end
