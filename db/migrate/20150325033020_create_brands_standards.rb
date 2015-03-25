class CreateBrandsStandards < ActiveRecord::Migration
  def change
    create_table :brands_standards, id: false do |t|
      t.references :standard, class_name: 'Standard', null: false
      t.references :brand, class_name: 'Brand', null: false
    end
  end
end
