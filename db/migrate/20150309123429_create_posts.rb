# encoding: utf-8

# author: depp.yu
# 寻车和资源在database mapper

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.column :user_id, References, class_name: 'User' # 资源或者寻车拥有者
      t.column :_type, Integer # 资源类型 0 => 资源， 1 => 寻车
      t.column :brand_id, References, class_name: 'Brand' # 所属品牌
      t.column :remark, String, limit: 160 # 备注
      t.column :base_car_id, References, class_name: 'BaseCar' # 基础数据
      t.column :standard, Integer, null: false # 规格 中规 美规等
      t.column :model, String, limit: 40, null: false # 车型
      t.column :style, String, limit: 60 # 款式
      t.column :outer_color, String, limit: 20, null: false # 外观
      t.column :inner_color, String, limit: 20, null: false # 内饰
      t.column :car_license_areas, String, limit: 60, null: false # 车辆上牌区域
      t.column :car_in_areas, String, limit: 60, null: false # 车辆所在区域
      t.column :take_car_date, Integer, default: 0 # 提车日期 
      t.column :expect_price, Decimal, precision: 10, scale: 2 # 期望成交价格
      t.column :discouts_way, Integer, null: false # 出价方式
      t.column :discounts_content, Decimal, precision: 10, scale: 2 # 出价内容
      t.column :status, Integer   
      t.timestamps null: false
    end
  end
end
