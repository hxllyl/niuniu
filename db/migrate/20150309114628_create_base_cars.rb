# encoding: utf-8

# author: depp.yu
# base_car 模型的database mapper

class CreateBaseCars < ActiveRecord::Migration
  def change
    create_table :base_cars do |t|
      t.column :base_price, :decimal, precision: 10, scale: 2 # 知道价钱，单位（元）
      t.references :brand_id, class_name: 'Brand' # 车辆品牌
      t.column :outer_color, :string, limit: 20 # 外观
      t.column :model, :string, limit: 30, null: false # 车型
      t.column :inner_color, :string, limit: 20 # 内饰
      t.column :standard, :integer # 车辆规格 中规 美规等
      t.column :style, :string, limit: 60 # 车辆款式
      t.column :NO, :string, limit: 12 # 行话(e: 9876)
      t.column :status, :integer 
      t.timestamps null: false
    end
  end
end
