# encoding: utf-8

class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.references :user, class_name: 'User'
      t.references :message, class_name: 'Message'
      t.column     :status, :integer, default: 0 
      t.timestamps
    end
    
    add_index(:user_messages, :user_id)
    add_index(:user_messages, :message_id)
  end
end
