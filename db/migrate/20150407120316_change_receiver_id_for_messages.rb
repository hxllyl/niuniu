# encoding: utf-8

class ChangeReceiverIdForMessages < ActiveRecord::Migration
  def change
    change_column :messages, :receiver_id, :integer, null: true
  end
end
