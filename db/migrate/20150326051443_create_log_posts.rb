class CreateLogPosts < ActiveRecord::Migration
  def change
    create_table :log_posts do |t|
      t.references :user, class_name: 'User'
      t.references :post, class_name: 'Post'
      t.string :method_name

      t.timestamps null: false
    end
    
    add_index(:log_posts, :user_id)
    add_index(:log_posts, :post_id)
    add_index(:log_posts, :method_name)
  end
end
