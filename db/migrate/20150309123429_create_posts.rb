# encoding: utf-8

# author: depp.yu
# 寻车和资源在database mapper

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :standard, class_name: 'Standard' # 规格 中规 美规等
      t.references :brand, class_name: 'Brand' # 所属品牌
      t.references :car_model, class_name: 'CarModel' # 所属车型
      t.references :base_car, class_name: 'BaseCar' # 所属车款
      t.references :user, class_name: 'User' # 资源或者寻车拥有者

      t.column :_type, :integer # 资源类型 0 => 资源， 1 => 寻车
      t.column :remark, :string, limit: 160 # 备注
      t.column :outer_color, :string, limit: 60, null: false # 外观
      t.column :inner_color, :string, limit: 60, null: false # 内饰
      t.column :car_license_areas, :string, limit: 60, null: false # 车辆上牌区域
      t.column :car_in_areas, :string, array: true, null: false, default: [] # 车辆所在区域
      t.column :take_car_date, :integer, default: 0 # 提车日期
      t.column :expect_price, :decimal, precision: 10, scale: 2 # 期望成交价格
      t.column :discount_way, :integer, null: false # 出价方式 1 优惠点数 2 优惠金额 3 加价金额 4 直接报价 5 电议
      t.column :discount_content, :decimal, precision: 10, scale: 2 # 出价内容
      t.column :status, :integer, default: 1 # 状态 0 未审核 1 已审核  2 已过期 3 已成交 -1 已删除
      t.column :onwer_set_count, :integer, default: 0 #个人用于手动置顶
      t.column :sys_set_count,   :integer, default: 0 #系统用于手动置顶
      t.timestamps null: false
    end
  end
end
