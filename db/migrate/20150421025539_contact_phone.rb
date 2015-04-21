class ContactPhone < ActiveRecord::Migration
  def change
    add_column :log_contact_phones, :remark, :text
  end
end
