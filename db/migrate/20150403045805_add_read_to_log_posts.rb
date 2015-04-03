class AddReadToLogPosts < ActiveRecord::Migration
  def change
    add_column :log_posts, :read, :boolean, default: false
  end
end
