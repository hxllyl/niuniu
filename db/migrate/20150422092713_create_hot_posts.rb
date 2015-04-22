class CreateHotPosts < ActiveRecord::Migration
  def change
    create_table :hot_posts do |t|
      t.references :post, class_name: 'Post', null: false
      t.timestamps null: false
    end
  end
end
