# encoding: utf-8

# author: depp.yu
# 区域在database mapper

class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.column :name, :string, limit: 20, null: false # 区域名称
      t.column :level, :integer # 行政级别 1 => 省级, 2 => 市级
      t.references :parent, class_name: 'Area'
      t.timestamps null: false
    end
    
    add_index(:areas, :name)
    add_index(:areas, :parent_id)
  end
end
