# encoding: utf-8

# author: depp.yu

class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.references :user, class_name: 'User'
      t.column :value, :string, limit: 50, null: false # token 值
      t.column :expired_at, :datetime # 过期日期
      t.column :status, :integer  
      t.timestamps null: false
    end
  end
end
