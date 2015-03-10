# encoding: utf-8

# author: depp.yu
# user模型的database mapper

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :name,   :string, limit: 15,  null: false # 用户名称
      t.column :mobile, :string, limit: 15, null: false # 用户手机号码 用于登陆
      t.column :_type,  :integer # 用户类型（原来该字段用户表示用户是4S用户，还是经销商用户，目前用level表示）
      t.column :company, :string, limit: 225 # 用户公司
      t.column :role, :string, limit: 30  # 用户角色
      t.references :area_id, class_name: 'Area' # 外键 -- 引用area类
      t.column :level, :integer, default: 0 # 用户等级 0 => 个人, 1 => 认证资源, 2 => 认证综展, 3 => 4S
      t.column :status, :integer, default: 0 # 新建状态, 1 => 后台审理通过, 2 => 后台审理未通过
      t.column :salt, :string, limit: 45, null: false # 密码加密关键字
      t.column :encrpt_password, :string, limit: 50 # 加密后密码 digest::SHA1.hexdigest加密
      t.timestamps null: false
    end
  end
end
