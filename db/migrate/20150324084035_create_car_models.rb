class CreateCarModels < ActiveRecord::Migration
  def change
    create_table :car_models do |t|
      t.references :standard, class_name: 'Standard', null: false # 规格与基础数据关联
      t.references :brand,    class_name: 'Brand', null: false # 车辆品牌

      t.column :name,   :string, null: false # 车型
      t.column :display_name, :string # 显示名称
      t.column :status, :integer, default: 1 # 1 激活 0 未激活
      t.column :click_counter, :integer, default: 0 #点击率，用于排序
      t.timestamps null: false
    end

    add_index(:car_models, :standard_id)
    add_index(:car_models, :brand_id)
    add_index(:car_models, :status)
  end
end
