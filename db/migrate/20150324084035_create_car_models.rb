class CreateCarModels < ActiveRecord::Migration
  def change
    create_table :car_models do |t|
      t.references :standard, class_name: 'Standard' # 规格与基础数据关联
      t.references :brand,    class_name: 'Brand' # 车辆品牌

      t.column :name,   :string, null: false # 车型
      t.column :status, :integer, default: 1 # 1 激活 0 未激活
      t.timestamps null: false
    end
  end
end
