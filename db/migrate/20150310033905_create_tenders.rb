# encoding: utf-8

# author: depp.yu
# 报价在database mapper

class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.references :post, class_name: 'Post' # 报价属于那个寻车
      t.references :user, class_name: 'User' # 报价属于那个人（谁报的价）
      t.column :price,   :decimal, precision: 10, scale: 2 # 报价的出价
      t.column :discouts_way, :integer, null: false # 出价方式 1 优惠点数 2 优惠金额 3 加价金额 4 直接报价
      t.column :discounts_content, :decimal, precision: 10, scale: 2 # 出价内容
      t.column :status,  :integer
      t.timestamps null: false
    end
  end
end
