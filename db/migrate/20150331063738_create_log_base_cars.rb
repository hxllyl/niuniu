class CreateLogBaseCars < ActiveRecord::Migration
  def change
    create_table :log_base_cars do |t|
      t.references :user, class_name: 'User'  # 操作人
      t.references :base_car, class_name: 'BaseCar' # 操作对象
      t.column :method_name, :string, null: false # base_car 属性
      t.column :content, :string, null: false # 属性内容

      t.timestamps null: false
    end
    
    add_index(:log_base_cars, :user_id)
    add_index(:log_base_cars, :base_car_id)
    add_index(:log_base_cars, :method_name)
  end
end
