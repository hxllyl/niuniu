# encoding: utf-8

# author: depp.yu
# 公司（预留）

class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.column :name, :string, limit: 225, null: false
      t.references :area, class_name: 'Area'
      t.column :status, :integer
      t.timestamps null: false
    end
  end
end
