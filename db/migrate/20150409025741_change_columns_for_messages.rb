# encoding: utf-8

class ChangeColumnsForMessages < ActiveRecord::Migration
  def change
    change_column :messages, :sender_id, :integer, null: true
    add_column :messages, :mask, :string, limit: 15
  end
end
