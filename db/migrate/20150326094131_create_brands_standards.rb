# encoding: utf-8

class CreateBrandsStandards < ActiveRecord::Migration
  def change
    create_table :brands_standards, id: false do |t|
      t.references :brand, class_name: 'Brand', null: false
      t.references :standard, class_name: 'Standard', null: false
    end

    add_index(:brands_standards, :brand_id)
    add_index(:brands_standards, :standard_id)
  end
end
