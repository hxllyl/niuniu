class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :title # banner 名称
      t.string :poi # 位置 上 中 下
      t.string :position # 排序
      t.string :image # 图片位置
      t.datetime :begin_at
      t.datetime :end_at
      t.string :use # 使用方式， 给 web 或 app
      t.string :redirect_way # 跳转方式

      t.timestamps
    end
  end
end