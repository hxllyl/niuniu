# encoding: utf-8

# author: depp.yu
# base_car 模型的database mapper

class CreateBaseCars < ActiveRecord::Migration
  def change
    create_table :base_cars do |t|
      t.column :base_price, :decimal, precision: 10, scale: 2 # 知道价钱，单位（元）
      t.references :brand, class_name: 'Brand' # 车辆品牌
      t.column :outer_color, :string, array: true # 外观
      t.column :model, :string, limit: 30, null: false # 车型
      t.column :inner_color, :string, array: true # 内饰
      t.references :standard, class_name: 'Standard' # 规格与基础数据关联
      t.column :style, :string, limit: 60 # 车辆款式
      t.column :NO, :string, limit: 12 # 行话(e: 9876)
      t.column :status, :integer, default: 0 # 0 激活 1 未激活 
      t.timestamps null: false
    end
  end
end
