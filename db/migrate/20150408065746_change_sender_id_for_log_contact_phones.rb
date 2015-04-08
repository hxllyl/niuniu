# encoding: utf-8

class ChangeSenderIdForLogContactPhones < ActiveRecord::Migration
  def change
    change_column :log_contact_phones, :sender_id, :integer, null: true
  end
end
