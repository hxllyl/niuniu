# encoding: utf-8

# author: depp.yu
# 车辆品牌database mapper

class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.column :name, String, limit: 40, null: false # 车辆名称
      t.column :status, Integer
      t.timestamps null: false
    end
  end
end
