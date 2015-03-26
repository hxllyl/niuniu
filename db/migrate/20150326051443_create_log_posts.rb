class CreateLogPosts < ActiveRecord::Migration
  def change
    create_table :log_posts do |t|
      t.references :user, class_name: 'User'
      t.references :post, class_name: 'Post'
      t.string :method_name

      t.timestamps null: false
    end
  end
end
