# encoding: utf-8

# author: depp.yu
# 寻车和资源在database mapper

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :standard, class_name: 'Standard', null: false # 规格 中规 美规等
      t.references :brand, class_name: 'Brand', null: false # 所属品牌
      t.references :car_model, class_name: 'CarModel', null: false # 所属车型
      t.references :base_car, class_name: 'BaseCar', null: false # 所属车款
      t.references :user, class_name: 'User', null: false # 资源或者寻车拥有者

      t.column :_type, :integer # 资源类型 0 => 资源， 1 => 寻车
      t.column :remark, :string, limit: 225 # 备注
      t.column :outer_color, :string, limit: 60, null: false # 外观
      t.column :inner_color, :string, limit: 60, null: false # 内饰
      t.column :car_license_area, :string, limit: 60, null: false # 车辆上牌区域
      t.column :car_in_area, :string # 车辆所在区域
      t.column :take_car_date, :integer, default: 0 # 提车日期
      t.column :expect_price, :decimal, precision: 10, scale: 2, default: 0.0 # 期望成交价格
      t.column :discount_way, :integer, null: false # 出价方式 1 优惠点数 2 优惠金额 3 加价金额 4 直接报价 5 电议
      t.column :discount_content, :decimal, precision: 10, scale: 2, default: 0.0 # 出价内容
      t.column :status, :integer, default: 1 # 状态 0 未审核 1 已审核  2 已过期 3 已成交 -1 已删除
      t.column :resource_type, :integer, null: false # 资源状态 0 现车 1 期货
      t.column :sys_set_count,   :integer, default: 0 #系统用于手动置顶
      t.column :channel, :integer, default: 0 # 用户自建还是系统创建 0 用户自建 1 系统创建
      t.column :position, :integer  # 客户定义资源位置
      t.timestamps null: false
    end

    add_index(:posts, :standard_id)
    add_index(:posts, :brand_id)
    add_index(:posts, :base_car_id)
    add_index(:posts, :user_id)
    add_index(:posts, :_type)
    add_index(:posts, [:outer_color, :inner_color])
    add_index(:posts, :expect_price)
    add_index(:posts, :status)
  end
end
