# encoding: utf-8

# author: depp.yu
# 报价在database mapper

class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.references :post, class_name: 'Post' # 报价属于那个寻车
      t.references :user, class_name: 'User' # 报价属于那个人（谁报的价）
      t.column :price,   :decimal, precision: 10, scale: 2, default: 0.0 # 报价的出价
      t.column :discount_way, :integer, null: false # 出价方式 1 优惠点数 2 优惠金额 3 加价金额 4 直接报价 5 电议
      t.column :discount_content, :decimal, precision: 10, scale: 2, default: 0.0 # 出价内容
      t.column :status,  :integer, default: 0 # 0 未成交 1 已成交 -1 已删除
      t.timestamps null: false
    end

    add_index(:tenders, :post_id)
    add_index(:tenders, :user_id)
    add_index(:tenders, :price)
    add_index(:tenders, :status)
  end
end
