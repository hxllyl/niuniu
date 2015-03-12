# encoding: utf-8

# author: depp.yu
# 报价在database mapper

class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.references :post, class_name: 'Post' # 报价属于那个寻车
      t.references :user, class_name: 'User' # 报价属于那个人（谁报的价）
      t.column :price,   :decimal, precision: 10, scale: 2 # 报价的出价
      t.column :status,  :integer
      t.timestamps null: false
    end
  end
end
