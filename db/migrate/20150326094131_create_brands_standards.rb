# encoding: utf-8

class CreateBrandsStandards < ActiveRecord::Migration
  def change
    create_table :brands_standards, id: false do |t|
      t.references :brand, class_name: 'Brand'
      t.references :standard, class_name: 'Standard'
    end
  end
end
