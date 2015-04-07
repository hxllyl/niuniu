# encoding: utf-8

# author: depp.yu
# base_car 模型的database mapper

class CreateBaseCars < ActiveRecord::Migration
  def change
    create_table :base_cars do |t|
      t.references :standard,   class_name: 'Standard', null: false # 规格与基础数据关联
      t.references :brand,      class_name: 'Brand', null: false # 车辆品牌
      t.references :car_model,  class_name: 'CarModel', null: false # 车型

      t.column :base_price, :decimal, precision: 10, scale: 2, default: 0.0 # 知道价钱，单位（元）
      t.column :outer_color, :string, array: true # 外观
      t.column :inner_color, :string, array: true # 内饰
      t.column :style, :string, limit: 60 # 车辆款式
      t.column :NO, :string, limit: 12, default: '' # 行话(e: 9876)
      t.column :status, :integer, default: 1 # 1 激活 0 未激活
      t.column :display_name, :string # 显示名称

      t.timestamps null: false
    end

    add_index(:base_cars, :style)
    add_index(:base_cars, :base_price)
    add_index(:base_cars, [:outer_color, :inner_color])
    add_index(:base_cars, :NO)
    add_index(:base_cars, :standard_id)
    add_index(:base_cars, :brand_id)
    add_index(:base_cars, :car_model_id)
  end
end
